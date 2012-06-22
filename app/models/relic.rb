# -*- encoding : utf-8 -*-
class Relic < ActiveRecord::Base
  has_many :suggestions
  belongs_to :place

  attr_accessible :dating_of_obj, :group, :id, :identification, :materail, :national_number, :number, :place_id, :register_number, :street, :internal_id, :source, :categories
  attr_accessible :dating_of_obj, :group, :id, :identification, :materail, :national_number, :number, :place_id, :register_number, :street, :internal_id, :source, :categories, :as => :admin


  validates :place_id, :presence => true
  include PlaceCaching

  attr_protected :id, :created_at, :update_at

  has_ancestry
  serialize :source

  serialize :tags, Array

  # versioning
  has_paper_trail :class_name => 'RelicVersion', :on => [:update, :destroy]

  include Tire::Model::Search

  # custom tire callback
  after_save do
    # always update root document
    root.tire.update_index
  end

  # create different index for testing
  index_name("#{Rails.env}-relics")

  settings :number_of_shards => 1, :number_of_replicas => 1,
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
          :filter    => "standard, pl_stop, pl_synonym, morfologik_stem, lowercase, asciifolding, unique"
        }
      }
    }

  mapping do
    with_options :index => :analyzed do |a|
      a.indexes :identification
      a.indexes :street
      a.indexes :register_number
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

  class << self

    def reindex objs
      index.delete
      index.create :mappings => tire.mapping_to_hash, :settings => tire.settings
      index.import objs
    end

    def search(params)
      tire.search(:load => true, :page => params[:page], :per_page => 100) do
        location = params[:location].to_s.split('-')

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

        filter :term, :place_id => location[3] if location.size > 3

        sort { by :id, 'asc' }
      end
    end

    def suggester q
      tire.search(:load => true, :per_page => 20) do
        q1 = (q.present? ? q : '*')
        query do
          boolean do
            must { string q1, :default_operator => "AND" }
          end
        end
        # # hack to use missing-filter
        # # http://www.elasticsearch.org/guide/reference/query-dsl/missing-filter.html
        # query_value = self.instance_variable_get("@query").instance_variable_get("@value")
        # query_value[:bool][:must] << { constant_score: { filter: { missing: { field: "ancestry" } } } }

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
        sort { by :id, 'asc' }
      end
    end

  end

  def to_indexed_json
    ids = [:voivodeship_id, :district_id, :commune_id, :place_id].zip(get_parent_ids)
    {
      :id               => id,
      :identification   => identification,
      :street           => street,
      :register_number  => register_number,
      :place_full_name  => place_full_name,
      :descendants      => self.descendants.map(&:to_descendant_hash)
    }.merge(Hash[ids]).to_json
  end

  def to_descendant_hash
    {
      :id               => id,
      :identification   => identification,
      :street           => street,
      :register_number  => register_number
    }
  end


  def full_identification
    "#{identification} (#{register_number}) datowanie: #{dating_of_obj}; ulica: #{street}"
  end

  def get_parent_ids
    [voivodeship_id, district_id, commune_id, place_id]
  end

  def next
    last_id = self.class.last.try(:id)
    next_id = self.id + 1
    while next_id <= last_id
      obj = self.class.find_by_id(next_id)
      return obj if obj
      next_id += 1
    end
    nil
  end

  def prev
    first_id = self.class.first.try(:id)
    prev_id = self.id - 1
    while prev_id >= first_id
      obj = self.class.find_by_id(prev_id)
      return obj if obj
      prev_id - 1
    end
    nil
  end

  def find_children
    nrelic = self.next

    if nrelic.group.blank? and nrelic.next.try(:group).present?
      nrelic.parent = self
      nrelic.save
      nrelic = nrelic.next
    end

    while nrelic.number.to_s =~ /1/ and nrelic.group.present?
      nrelic.parent = self
      nrelic.save
      nrelic = nrelic.next
    end
  end

  def place_full_name
    [voivodeship.name, district.name, commune.name, place.name].join(', ')
  end

end
