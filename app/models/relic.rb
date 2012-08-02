# -*- encoding : utf-8 -*-
require 'relic/tire_extensions'
class Relic < ActiveRecord::Base
  States = ['checked', 'unchecked', 'filled']
  Existences = ['existed', 'archived', 'social']

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
          :filter    => "standard, lowercase, pl_synonym, pl_stop, morfologik_stem, unique"
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
      na.indexes :virtual_commune_id
      na.indexes :categories
      na.indexes :has_photos,       :type => "boolean"
      na.indexes :has_description,  :type => "boolean"
      na.indexes :state
      na.indexes :existance

      # backward compatibility
      na.indexes :voivodeship_id
      na.indexes :district_id
      na.indexes :commune_id
      na.indexes :place_id
    end
  end

  class << self

    def reindex objs
      index.delete
      index.create :mappings => tire.mapping_to_hash, :settings => tire.settings
      index.import objs
      index.refresh
    end

    def analyze_query q
      analyzed = Relic.index.analyze q
      return '*' if !analyzed or (analyzed and analyzed['tokens'].blank?)
      analyzed['tokens'].group_by{|i| i['position']}.inject([]) do |s1, (k, v)|
        s1 << v.inject([]) {|s2, t| s2 << "#{t['token']}*"; s2}.join(' OR ')
        s1
      end.join(' ')
    end

    def next_for(user, search_params)
      params = (search_params || {}).merge(:per_page => 1, :seen_relic_ids => user.seen_relic_ids, :corrected_relic_ids => user.corrected_relic_ids)
      self.search(params).first || self.first(:offset => rand(self.count))
    end

    def next_random_in(conditions)
      self.where(conditions).first(:offset => rand(self.where(conditions).count))
    end

    def next_few_for(user, search_params, count)
      params = (search_params || {}).merge(:per_page => count, :corrected_relic_ids => user.corrected_relic_ids)
      res = self.search(params).take(count)
      res.empty? ? self.where(:offset => rand(self.count)).limit(count) : res
    end

  end

  def to_indexed_json
    # backward compatibility
    ids = [:voivodeship_id, :district_id, :commune_id, :place_id].zip(get_parent_ids)
    {
      :id               => id,
      :identification   => identification,
      :street           => street,
      :place_full_name  => place_full_name,
      # :kind             => kind,
      :descendants      => self.descendants.map(&:to_descendant_hash),
      :edit_count       => self.edit_count,
      :skip_count       => self.skip_count,
      :voivodeship      => { :id => self.voivodeship_id,            :name => self.voivodeship.name },
      :district         => { :id => self.district_id,               :name => self.district.name },
      :commune          => { :id => self.commune_id,                :name => self.commune.name },
      :virtual_commune_id => self.place.virtual_commune_id,
      :place            => { :id => self.place_id,                  :name => self.place.name },
      # new search fields
      :description      => 'some description',
      :has_description  => true,
      # :from             => '',
      # :to               => '',
      # sample categoires
      :categories       => Tag.all.values.sample(3),
      :has_photos       => [true, false].sample,
      :state            => States.sample,
      :existance        => Existences.sample
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
