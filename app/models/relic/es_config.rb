# -*- encoding : utf-8 -*-
# ElasticSearch Config in one place
module Relic::EsConfig
  extend ActiveSupport::Concern

  included do
    include Tire::Model::Search
    # create different index for testing
    index_name("#{Settings.oz.index_env}-relics")

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
            :filter    => "standard, lowercase, pl_synonym, pl_stop, morfologik_stem, unique, lowercase"
          }
        }
      }

    mapping do
      indexes :identification, :type => "multi_field", :fields => {
        :identification =>  { "type" => "string", "index" => "analyzed" },
        :untouched =>  { "type" => "string", "index" => "not_analyzed" }
      }
      indexes :fprovince, :type => "multi_field", :fields => {
        :fprovince =>  { "type" => "string", "index" => "analyzed" },
        :untouched =>  { "type" => "string", "index" => "not_analyzed" }
      }
      indexes :fplace, :type => "multi_field", :fields => {
        :fplace =>  { "type" => "string", "index" => "analyzed" },
        :untouched =>  { "type" => "string", "index" => "not_analyzed" }
      }
      indexes :autocomplitions, :type => "multi_field", :fields => {
        :autocomplitions =>  { "type" => "string", "index" => "analyzed" },
        :untouched =>  { "type" => "string", "index" => "not_analyzed" }
      }
      indexes :tags, :type => "multi_field", :fields => {
        :tags =>  { "type" => "string", "index" => "analyzed" },
        :untouched =>  { "type" => "string", "index" => "not_analyzed" }
      }
      indexes :street_normalized, :type => "multi_field", :fields => {
        :street_normalized =>  { "type" => "string", "index" => "analyzed" },
        :untouched =>  { "type" => "string", "index" => "not_analyzed" }
      }
      indexes :coordinates, :type => "geo_point"
      with_options :index => :not_analyzed do |na|
        na.indexes :id
        na.indexes :kind
        na.indexes :virtual_commune_id
        na.indexes :categories
        na.indexes :has_photos,       :type => "boolean"
        na.indexes :has_description,  :type => "boolean"
        na.indexes :state
        na.indexes :existence

        na.indexes :has_round_date,  :type => "boolean"
        na.indexes :from,  :type => "integer"
        na.indexes :to,  :type => "integer"
        na.indexes :country
      end
    end

    # custom tire callback
    after_save do
      # always update root document
      if build_finished?
        root.tire.update_index
        Rails.cache.delete('views/browse-list')
      end
    end

    after_destroy do
      tire.update_index
      Rails.cache.delete('views/browse-list')
    end
  end

  module ClassMethods
    def reindex(objs)
      index.delete
      index.create :mappings => tire.mapping_to_hash, :settings => tire.settings
      index.import objs
      index.refresh
    end

    def reindex_sample(amount = 100, delete = true)
      index.delete if delete
      index.create :mappings => tire.mapping_to_hash, :settings => tire.settings
      index.import Relic.roots.select('DISTINCT identification, *').limit(amount).map(&:sample_json)
      index.refresh
    end
  end

  def sample_json
    dp = DateParser.new ['1 cw XX', '1916', '1907-1909'].sample
    dating_hash = Hash[[:from, :to, :has_round_date].zip(dp.results << dp.rounded?)]
    {
      :id               => id,
      :slug             => to_param,
      :type             => 'relic',
      :identification   => identification,
      :common_name      => common_name,
      :street           => street,
      :place_full_name  => place_full_name,
      :descendants      => self.descendants.map(&:to_descendant_hash),

      :voivodeship      => { :id => self.voivodeship_id,            :name => self.voivodeship.name },
      :district         => { :id => self.district_id,               :name => self.district.name },
      :commune          => { :id => self.commune_id,                :name => self.commune.name },
      :virtual_commune_id => self.place.virtual_commune_id,
      :place            => { :id => self.place_id,                  :name => self.place.name },
      # new search fields
      :categories       => (Category.to_hash.keys - ['sakralny']).sample(3),
      :has_photos       => [true, false].sample,
      :state            => state,
      :existence        => existence,
      :country          => ['pl', 'de', 'gb'].sample,
      :tags             => ['WaWel', 'ZameK', 'zespół pałacowy', 'zamek królewski'].shuffle.first(rand(2) + 1).shuffle.first(rand(4) + 1),
      :autocomplitions  => ['puchatka', 'szlachciatka', 'chata polska', 'chata mazurska', 'chata wielkopolska'].shuffle.first(rand(4) + 1),
      # Lat Lon As Array Format in [lon, lat]
      :coordinates       => [longitude, latitude]
    }.merge(dating_hash)
  end

  def to_indexed_hash
    dp = DateParser.new dating_of_obj
    dating_hash = Hash[[:from, :to, :has_round_date].zip(dp.results << dp.rounded?)]
    {
      :id                   => id,
      :slug                 => to_param,
      :type                 => 'relic',
      :identification       => identification,
      :common_name          => common_name,
      :street               => street,
      :street_normalized    => street(true),
      :place_full_name      => place_full_name,
      :place_with_address   => place_with_address(true),
      :descendants          => self.descendants.map(&:to_descendant_hash),
      :voivodeship          => { :id => self.voivodeship_id,   :name => self.voivodeship.name },
      :district             => { :id => self.district_id,      :name => self.district.name },
      :commune              => { :id => self.commune_id,       :name => self.commune.name },
      :virtual_commune_id   => self.place.virtual_commune_id,
      :place                => { :id => self.place_id,         :name => self.place.name },
      # new fields
      :description          => description,
      :has_description      => description?,
      :categories           => categories,
      :has_photos           => has_photos?,
      :state                => state,
      :existence            => existence,
      :country              => country_code.downcase,
      :tags                 => tags,
      # Lat Lon As Array Format in [lon, lat]
      :coordinates          => [longitude, latitude]
    }.merge(dating_hash)
  end

  def to_indexed_json
    to_indexed_hash.to_json
  end

  def to_descendant_hash
    {
      :id               => id,
      :identification   => identification,
      :common_name      => common_name,
      :street           => street,
      :place_with_address  => place_with_address(true)
    }
  end
end
