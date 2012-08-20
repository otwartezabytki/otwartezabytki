# == Schema Information
#
# Table name: relics
#
#  id              :integer          not null, primary key
#  place_id        :integer
#  identification  :text
#  group           :string(255)
#  number          :integer
#  materail        :string(255)
#  dating_of_obj   :string(255)
#  street          :string(255)
#  register_number :text
#  nid_id          :string(255)
#  latitude        :float
#  longitude       :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  internal_id     :string(255)
#  ancestry        :string(255)
#  source          :text
#  commune_id      :integer
#  district_id     :integer
#  voivodeship_id  :integer
#  register_date   :date
#  date_norm       :string(255)
#  date_start      :string(255)
#  date_end        :string(255)
#  kind            :string(255)
#  approved        :boolean          default(FALSE)
#  categories      :string(255)
#  skip_count      :integer          default(0)
#  edit_count      :integer          default(0)
#  description     :text
#  tags            :string(255)
#  type            :string(255)      default("Relic")
#  country_code    :string(255)      default("PL")
#  fprovince       :string(255)
#  fplace          :string(255)
#  documents_info  :text
#  links_info      :text
#  user_id         :integer
#

# -*- encoding : utf-8 -*-
ActiveSupport::Dependencies.depend_on 'relic/tire_extensions'
class Relic < ActiveRecord::Base
  States = ['checked', 'unchecked', 'filled']
  Existences = ['existed', 'archived', 'social']

  has_ancestry

  belongs_to :user
  belongs_to :place

  has_many :documents, :dependent => :destroy
  has_many :photos, :dependent => :destroy
  has_many :alerts, :dependent => :destroy
  has_many :entries, :dependent => :destroy
  has_many :links, :order => 'position', :dependent => :destroy
  has_many :events, :order => 'position', :dependent => :destroy

  attr_accessor :license_agreement
  attr_accessible :identification, :place_id, :dating_of_obj, :latitude, :longitude,
                  :street, :tags, :categories, :photos_attributes, :description,
                  :documents_attributes, :documents_info, :links_attributes, :links_info,
                  :events_attributes, :entries_attributes, :license_agreement, :user_id, :user

  accepts_nested_attributes_for :photos, :documents, :entries, :links, :events, :allow_destroy => true

  include PlaceCaching
  include Validations

  serialize :source
  serialize :tags, Array
  serialize :categories, Array

  validates :identification, :presence => true, :if => :identification_changed?

  before_validation do
    if tags_changed? && tags.is_a?(Array)
      tmp = []
      self.tags.each do |tag|
        tmp += tag.split(',').map(&:strip) if tag.present?
      end
      self.tags = tmp
    end
  end

  before_validation do
    if categories_changed? && categories.is_a?(Array)
      tmp = []
      self.categories.each do |category|
        tmp += category.split(',').map(&:strip) if category.present?
      end
      self.categories = tmp
    end
  end

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

      na.indexes :has_round_date,  :type => "boolean"
      na.indexes :from,  :type => "integer"
      na.indexes :to,  :type => "integer"
      na.indexes :country
      na.indexes :street_normalized
      na.indexes :tags
    end
  end

  class << self

    def reindex objs
      index.delete
      index.create :mappings => tire.mapping_to_hash, :settings => tire.settings
      index.import objs
      index.refresh
    end

    def reindex_sample amount = 100
      index.delete
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
      :type             => 'relic',
      :identification   => identification,
      :street           => street,
      :street_normalized => street_normalized,
      :place_full_name  => place_full_name,
      # :kind             => kind,
      :descendants      => self.descendants.map(&:to_descendant_hash),
      # :edit_count       => self.edit_count,
      # :skip_count       => self.skip_count,
      :voivodeship      => { :id => self.voivodeship_id,            :name => self.voivodeship.name },
      :district         => { :id => self.district_id,               :name => self.district.name },
      :commune          => { :id => self.commune_id,                :name => self.commune.name },
      :virtual_commune_id => self.place.virtual_commune_id,
      :place            => { :id => self.place_id,                  :name => self.place.name },
      # new search fields
      :categories       => Category.all.values.sample(3),
      :has_photos       => [true, false].sample,
      :state            => States.sample,
      :existance        => Existences.sample,
      :country          => ['pl', 'de', 'gb'].sample,
      :tags             => ['wawel', 'zamek', 'zespół pałacowy', 'zamek królewski'].shuffle.first(rand(2) + 1).shuffle.first(rand(4) + 1),
      :autocomplitions  => ['puchatka', 'szlachciatka', 'chata polska', 'chata mazurska', 'chata wielkopolska'].shuffle.first(rand(4) + 1)
    }.merge(dating_hash)
  end

  def to_indexed_json
    dp = DateParser.new dating_of_obj
    dating_hash = Hash[[:from, :to, :has_round_date].zip(dp.results << dp.rounded?)]
    {
      :id               => id,
      :type             => 'relic',
      :identification   => identification,
      :street           => street,
      :street_normalized => street_normalized,
      :place_full_name  => place_full_name,
      # :kind             => kind,
      :descendants      => self.descendants.map(&:to_descendant_hash),
      # :edit_count       => self.edit_count,
      # :skip_count       => self.skip_count,
      :voivodeship      => { :id => self.voivodeship_id,            :name => self.voivodeship.name },
      :district         => { :id => self.district_id,               :name => self.district.name },
      :commune          => { :id => self.commune_id,                :name => self.commune.name },
      :virtual_commune_id => self.place.virtual_commune_id,
      :place            => { :id => self.place_id,                  :name => self.place.name },
      # new fields
      :description      => description,
      :has_description  => description?,
      :categories       => categories,
      :has_photos       => has_photos?,
      :state            => state,
      :existance        => existance,
      :country          => country_code.downcase,
      :tags             => tags
    }.merge(dating_hash).to_json
  end

  def to_descendant_hash
    {
      :id               => id,
      :identification   => identification,
      :street           => street,
    }
  end

  def street_normalized
    street_normalized = street.split('/').first.to_s
    street_normalized.gsub!(/[\W\d]+$/i, '')
    street_normalized.gsub!(/\d+[a-z]?([i,\/\s]+)?\d+[a-z]$/i, '')
    street_normalized.strip!
    street_normalized
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

  def status
    :checked_but_not_filled
  end

  def country_code= value
    @country_code = (value || 'pl').upcase
  end

  def country
    I18n.t(country_code.upcase, :scope => 'countries')
  end

  def main_photo
    @main_photo ||= self.photos.where(:main => true).first || self.photos.first
  end

  # @return photos for relic and it's descendants
  def all_photos
    Photo.where(:relic_id => [id] + descendant_ids)
  end

  def has_photos?
    all_photos.exists?
  end

  def state
    # TODO
    States.sample
  end

  def existance
    # TODO
    Existences.sample
  end

  private

  def fill_user(resource)
    Rails.logger.info("foobar")
    resource.user = user
  end
end
