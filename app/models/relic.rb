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
      na.indexes :voivodeship_id
      na.indexes :district_id
      na.indexes :commune_id
      na.indexes :place_id
      na.indexes :ancestry
    end
  end
  Tire.configure { logger 'log/elasticsearch.log' }

  Tire::Results::Collection.class_eval do
    def highlighted_tags
      return @highlighted_tags if defined? @highlighted_tags
      @highlighted_tags = @response['hits']['hits'].inject([]) do |m, h|
        m << h['highlight'].values.join.scan(/<em>(.*?)<\/em>/) if h['highlight']
        m
      end.flatten.uniq.select{|w| w.size > 1}.sort_by{|w| -w.size}
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

    def search(params)
      tire.search(:load => false, :page => params[:page], :per_page => 10) do
        location = params[:location].to_s.split('-')
        corrected_relic_ids = (params[:corrected_relic_ids] || []).map(&:to_s)

        q1 = (params[:q1].present? ? params[:q1] : '*')
        query do
          boolean do
            must { string q1, :default_operator => "AND" }
          end
        end
        # # hack to use missing-filter
        # # http://www.elasticsearch.org/guide/reference/query-dsl/missing-filter.html
        # query_value = self.instance_variable_get("@query").instance_variable_get("@value")
        # query_value[:bool][:must] << { constant_score: { filter: { missing: { field: "ancestry" } } } }

        highlight "identification" => {},
          "street" => {},
          "register_number" => {},
          "place_full_name" => {},
          "descendants.identification" => {},
          "descendants.street" => {},
          "descendants.register_number" => {}

        facet "voivodeships" do
          terms :voivodeship_id, :size => 16
        end

        if location.size > 0
          filter :term, :voivodeship_id => location[0]
          facet "districts", :facet_filter => { :term => { :voivodeship_id => location[0] } } do
            terms :district_id, :size => 10_000
          end
        end

        if location.size > 1
          filter :term, :district_id => location[1]
          facet "communes", :facet_filter => { :term => { :district_id => location[1] } } do
            terms :commune_id, :size => 10_000
          end
        end

        if location.size > 2
          filter :term, :commune_id => location[2]
          facet "places", :facet_filter => { :term => { :commune_id => location[2] } } do
            terms :place_id, :size => 10_000
          end
        end

        facet "corrected" do
          terms :edit_count, :script => %Q(
            (#{corrected_relic_ids.to_json}.indexOf(doc['id'].value.toString()) > -1 || doc['edit_count'].value > 2) ? 1 : 0
          ).squish, :all_terms => true
        end

        filter :term, :place_id => location[3] if location.size > 3

        sort do
          by '_script', {
              'script' => %q(
                f0 = doc['edit_count'].value * f1 - doc['skip_count'].value;
                if( corrected_relic_ids.indexOf(doc['id'].value.toString()) > -1 || doc['edit_count'].value > 2 ) { f2 + f0; } else { f0; }
              ).squish,
              'type' => 'number',
              'params' => {
                'f1' => 1000,
                'f2' => -100_000_000,
                'corrected_relic_ids' => corrected_relic_ids
              },
              'order' => 'desc'
            }
          by '_score', 'desc'
        end
      end
    end

    def suggester q
      tire.search(:load => false, :per_page => 1) do
        q1 = (q.present? ? q : '*')
        query do
          boolean do
            must { string q1, :default_operator => "AND" }
          end
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
      params = (search_params || {}).merge(:limit => 1, :corrected_relic_ids => user.corrected_relic_ids)
      self.search(params).first || self.first(:offset => rand(self.count))
    end

  end

  def to_indexed_json
    ids = [:voivodeship_id, :district_id, :commune_id, :place_id].zip(get_parent_ids)
    {
      :id               => id,
      :identification   => identification,
      :street           => street,
      # :register_number  => register_number,
      :place_full_name  => place_full_name,
      :kind             => kind,
      :dating_of_obj    => dating_of_obj,
      :descendants      => self.descendants.map(&:to_descendant_hash),
      :edit_count       => edit_count,
      :skip_count       => skip_count
    }.merge(Hash[ids]).to_json
  end

  def to_descendant_hash
    {
      :id               => id,
      :identification   => identification,
      :street           => street,
      # :register_number  => register_number
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

end
