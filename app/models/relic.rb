# -*- encoding : utf-8 -*-
class Relic < ActiveRecord::Base
  has_many :suggestions
  belongs_to :place

  attr_protected :id, :created_at, :update_at
  attr_accessible :dating_of_obj, :group, :id, :identification, :materail, :national_number, :number, :place_id, :register_number, :street, :internal_id, :source, :tags
  attr_accessible :dating_of_obj, :group, :id, :identification, :materail, :national_number, :number, :place_id, :register_number, :street, :internal_id, :source, :tags, :as => :admin

  include PlaceCaching
  include Validations

  has_ancestry

  serialize :source
  serialize :tags, Array

  # versioning
  has_paper_trail :class_name => 'RelicVersion', :on => [:update, :destroy]

  include Tire::Model::Search

  # custom tire callback
  after_save :update_relic_index

  # create different index for testing
  index_name("#{Rails.env}-relics")

  settings :number_of_shards => 5, :number_of_replicas => 1,
    :analysis => {
      :filter => {
        :pl_stop => {
          :type           => "stop",
          :ignore_case    => true,
          :stopwords_path => "#{Rails.root}/config/elasticsearch/stopwords.txt"
        },
        :pl_synonym => {
          :type           => "synonym",
          :ignore_case    => true,
          :expand         => false,
          :synonyms_path  => "#{Rails.root}/config/elasticsearch/synonyms.txt"
        }
      },
      :analyzer => {
        :default => {
          :type      => "custom",
          :tokenizer => "standard",
          :filter    => "standard, lowercase, pl_synonym, pl_stop, morfologik_stem, lowercase, asciifolding, unique"
        }
      }
    }

  mapping do
    with_options :index => :analyzed do |a|
      a.indexes :identification
      a.indexes :street
    end
    with_options :index => :not_analyzed do |na|
      na.indexes :id
      na.indexes :kind
      na.indexes :edit_count, :type => "integer"
      na.indexes :skip_count, :type => "integer"
      na.indexes :voivodeship_id
      na.indexes :district_id
      na.indexes :commune_id
      na.indexes :virtual_commune_id
      na.indexes :place_id
    end
  end
  Tire.configure { logger 'log/elasticsearch.log' }

  Tire::Results::Collection.class_eval do
    def highlighted_tags
      return @highlighted_tags if defined? @highlighted_tags
      @highlighted_tags = @response['hits']['hits'].inject([]) do |m, h|
        m << h['highlight'].values.join.scan(/<em>(.*?)<\/em>/) if h['highlight']
        m
      end.flatten.uniq.select{|w| w.size > 1}.sort_by{|w| -w.size}.map{ |t| Unicode.downcase(t) }
    end

    def correct_count
      return @correct_count if defined? @correct_count
      @correct_count = self.facets['corrected']['terms'].select {|a| a['term'] == 1}.first['count'] rescue 0
    end

    def incorrect_count
      return @incorrect_count if defined? @incorrect_count
      @incorrect_count = self.facets['corrected']['terms'].select {|a| a['term'] == 0}.first['count'] rescue 0
    end
  end

  Tire::Results::Item.class_eval do
    def corrected?(user = nil)
      @is_corrected ||= {}
      return @is_corrected[user.try(:id)] if @is_corrected[user.try(:id)]
      @is_corrected[user.try(:id)] = (!!user and user.corrected_relic_ids.include?(self[:id].to_i)) or self[:edit_count] > 2
    end
  end

  class << self

    def reindex objs
      index.delete
      index.create :mappings => tire.mapping_to_hash, :settings => tire.settings
      index.import objs
    end

    def analyze_query q
      analyzed = Relic.index.analyze q
      analyzed ? analyzed['tokens'].inject("") { |s, t| s << " #{t['token']}*"; s } : '*'
    end

    def search(params)
      tire.search(:load => false, :page => params[:page], :per_page => 10) do
        location = params[:location].to_s.split('-').map {|l| l.split(':') }
        corrected_relic_ids = (params[:corrected_relic_ids] || []).map(&:to_s)
        seen_relic_ids =(params[:seen_relic_ids]||[]).map(&:to_s)

        q1 = Relic.analyze_query params[:q1]
        query do
          boolean do
            must { string q1, :default_operator => "AND", :fields => [
              "identification^5",
              "street",
              "place_full_name^2",
              "descendants.identification^3"              ]
            }
          end
        end
        # # hack to use missing-filter
        # # http://www.elasticsearch.org/guide/reference/query-dsl/missing-filter.html
        # query_value = self.instance_variable_get("@query").instance_variable_get("@value")
        # query_value[:bool][:must] << { constant_score: { filter: { missing: { field: "ancestry" } } } }
        if q1 != '*'
          highlight "identification" => {},
            "street" => {},
            "place_full_name" => {},
            "descendants.identification" => {},
            "descendants.street" => {}
        end
        facet "voivodeships" do
          terms :voivodeship_id, :size => 16
        end

        if location.size > 0
          filter :terms, :voivodeship_id => location[0]
          facet "districts", :facet_filter => { :terms => { :voivodeship_id => location[0] } } do
            terms :district_id, :size => 10_000
          end
        end

        if location.size > 1
          filter :terms, :district_id => location[1]
          facet "communes", :facet_filter => { :terms => { :district_id => location[1] } } do
            terms :virtual_commune_id, :size => 10_000
          end
        end

        if location.size > 2
          filter :terms, :commune_id => location[2]
          facet "places", :facet_filter => { :terms => { :commune_id => location[2]} } do
            terms :place_id, :size => 10_000
          end
        end

        filter :terms, :place_id => location[3] if location.size > 3

        facet "overall" do
          terms :id, :script => 1, :global => true, :all_terms => true
        end

        corrected_faset_filter = {}
        term_params = Hash[
          [:voivodeship_id, :district_id, :commune_id, :place_id].zip(location)
        ].inject({}) { |mem, (k, v)| mem[k] = v.split(':') if v; mem }
        corrected_faset_filter = { :facet_filter => { :terms => term_params } } if term_params.present?

        facet "corrected", corrected_faset_filter do
          terms :edit_count, :script => "(corrected_relic_ids.contains(doc['id'].value.toString()) || doc['edit_count'].value > 2) ? 1 : 0", :all_terms => true, :params => {
            'corrected_relic_ids' => corrected_relic_ids
          }
        end
        sort do
          by '_script', {
              'script' => %q(
                i = -seen_relic_ids.indexOf(doc['id'].value.toString());
                f0 = (i * 100) + (doc['edit_count'].value * f1) - doc['skip_count'].value;
                if( corrected_relic_ids.contains(doc['id'].value.toString()) || doc['edit_count'].value > 2 ) { f2 + f0; } else { f0; }
              ).squish,
              'type' => 'number',
              'params' => {
                'f1' => 100,
                'f2' => -100_000_000,
                'corrected_relic_ids' => corrected_relic_ids,
                'seen_relic_ids' => seen_relic_ids
              },
              'order' => 'desc'
            }
          by '_score', 'desc'
        end
      end
    end

    def suggester q
      tire.search(:load => false, :per_page => 1) do
        query do
          boolean do
            must { string Relic.analyze_query(q),:default_operator => "AND" }
          end
        end
        if q != '*'
          highlight "identification" => {},
            "street" => {},
            "place_full_name" => {},
            "descendants.identification" => {},
            "descendants.street" => {}
        end

        facet "voivodeships" do
          terms :voivodeship_id, :size => 3
        end
        facet "districts" do
          terms :district_id, :size => 3
        end
        facet "communes" do
          terms :commune_id, :size => 3
        end
        facet "places" do
          terms :place_id, :size => 3
        end
      end
    end

    def next_for(user, search_params)
      params = (search_params || {}).merge(:per_page => 1, :seen_relic_ids => user.seen_relic_ids, :corrected_relic_ids => user.corrected_relic_ids)
      self.search(params).first || self.first(:offset => rand(self.count))
    end

    def next_few_for(user, search_params, count)
      params = (search_params || {}).merge(:per_page => count, :corrected_relic_ids => user.corrected_relic_ids)
      res = self.search(params).take(count)
      res.empty? ? self.where(:offset => rand(self.count)).limit(count) : res
    end

  end

  def to_indexed_json
    ids = [:voivodeship_id, :district_id, :commune_id, :place_id].zip(get_parent_ids)
    {
      :id               => id,
      :identification   => identification,
      :street           => street,
      :place_full_name  => place_full_name,
      :kind             => kind,
      :descendants      => self.descendants.map(&:to_descendant_hash),
      :edit_count       => self.edit_count,
      :skip_count       => self.skip_count,
      :virtual_commune_id => self.place.virtual_commune_id
    }.merge(Hash[ids]).to_json
  end

  def to_descendant_hash
    {
      :id               => id,
      :identification   => identification,
      :street           => street,
    }
  end


  def full_identification
    "#{identification} (#{register_number}) datowanie: #{dating_of_obj}; ulica: #{street}"
  end

  def get_parent_ids
    [voivodeship_id, district_id, commune_id, place_id]
  end

  def place_full_name(include_place = true)
    if self.has_children?
      descendants_locations = self.descendants.map{ |d|  { :district => d.district_id, :commune => d.commune_id, :place => d.place_id } }

      same_district = descendants_locations.map{ |l| l[:district] }.uniq.size == 1
      same_commune = descendants_locations.map{ |l| l[:commune] }.uniq.size == 1
      same_place = descendants_locations.map{ |l| l[:place] }.uniq.size == 1

      location =  ["woj. #{voivodeship.name}"]
      location += ["pow. #{district.name}"] if same_district
      location += ["gm. #{commune.name}"] if same_commune
      location += [place.name] if same_place && include_place

      location.join(', ')
    else
      ["woj. #{voivodeship.name}", "pow. #{district.name}", "gm. #{commune.name}", place.name].join(', ')
    end

  end

  def update_relic_index
    # always update root document
    root.tire.update_index
  end

  def corrected_by?(user)
    user.suggestions.where(:relic_id => self.id).count > 0
  end

  def corrected?
    suggestions.count >= 3
  end

end
