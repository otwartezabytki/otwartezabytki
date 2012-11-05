# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: relics
#
#  id              :integer          not null, primary key
#  place_id        :integer
#  identification  :text
#  dating_of_obj   :string(255)
#  street          :string(255)
#  register_number :text
#  nid_id          :string(255)
#  latitude        :float
#  longitude       :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  ancestry        :string(255)
#  commune_id      :integer
#  district_id     :integer
#  voivodeship_id  :integer
#  kind            :string(255)
#  approved        :boolean          default(FALSE)
#  categories      :string(255)
#  description     :text             default("")
#  tags            :string(255)
#  type            :string(255)      default("Relic")
#  country_code    :string(255)      default("PL")
#  fprovince       :string(255)
#  fplace          :string(255)
#  documents_info  :text
#  links_info      :text
#  user_id         :integer
#  geocoded        :boolean
#  build_state     :string(255)
#  reason          :text
#  date_start      :integer
#  date_end        :integer
#  state           :string(255)      default("unchecked")
#  existence       :string(255)      default("existed")
#  common_name     :string(255)      default("")
#

ActiveSupport::Dependencies.depend_on 'relic/tire_extensions'
class Relic < ActiveRecord::Base
  include AASM
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
  has_many :events, :order => 'date_start', :dependent => :destroy

  attr_accessor :license_agreement, :polish_relic, :created_via_api
  attr_accessible :identification, :place_id, :dating_of_obj, :latitude, :longitude,
                  :street, :tags, :categories, :photos_attributes, :description,
                  :documents_attributes, :documents_info, :links_attributes, :links_info,
                  :events_attributes, :entries_attributes, :license_agreement, :polish_relic,
                  :geocoded, :build_state, :parent_id, :common_name, :as => [:default, :admin]

  attr_accessible :ancestry, :register_number, :approved, :state, :existence, :as => :admin

  accepts_nested_attributes_for :photos, :documents, :entries, :links, :events, :allow_destroy => true

  include PlaceCaching
  include Validations

  serialize :source
  serialize :tags, Array
  serialize :categories, Array

  scope :created, where(:build_state => 'finish_step')

  aasm :column => :build_state do
    state :create_step, :initial => true
    state :address_step
    state :details_step
    state :photos_step
    state :finish_step
  end

  before_validation :parse_date

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

  # mark new created relics as social added
  before_create do
    self.existence = 'social'
  end

  validates :state, :inclusion => { :in => States }, :if => :state_changed?
  validates :existence, :inclusion => { :in => Existences }, :if => :existence_changed?

  # versioning
  has_paper_trail :skip => [:updated_at, :created_at, :user_id, :build_state, :kind, :date_start, :date_end,
    :type, :commune_id, :district_id, :voivodeship_id, :geocoded, :reason]

  include Tire::Model::Search

  # custom tire callback
  after_save :update_relic_index

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

  class << self
    def recently_modified_revisions
      Version.select('DISTINCT ON (item_id) * ')
        .order('item_id, versions.id DESC')
        .where(:item_type => 'Relic', :event => 'update')
        .joins("INNER JOIN relics on relics.id = versions.item_id AND relics.build_state = 'finish_step'")
        .last(5).reverse
    end

    def random_filled
      conds = { :state => 'filled' }
      relics_count = self.where(conds).count
      if relics_count.zero?
        conds[:state] = 'checked'
        relics_count = self.where(conds).count
      end
      self.where(conds).offset(rand(relics_count)).first || self.offset(rand(self.count)).first
    end

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
      :street_normalized    => street_normalized,
      :place_full_name      => place_full_name,
      :place_with_address   => place_with_address,
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
    }
  end

  def street_normalized
    street_normalized = street.to_s.split('/').first.to_s
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
    root.tire.update_index if build_finished?
  end

  def corrected_by?(user)
    user.suggestions.where(:relic_id => self.id).count > 0
  end

  def corrected?
    suggestions.count >= 3
  end

  def country_code= value
    self[:country_code] = (value || 'pl').upcase
  end

  def country
    I18n.t(country_code.upcase, :scope => 'countries')
  end

  def main_photo
    return @main_photo if defined? @main_photo
    @main_photo = (self.all_photos.order('CASE(photos.main) WHEN TRUE THEN 0 ELSE 1 END').first || self.photos.new)
  end

  # @return photos for relic and it's descendants
  def all_photos
    Photo.where(:relic_id => [id] + descendant_ids)
  end

  def has_photos?
    all_photos.exists?
  end

  def all_documents
    Document.where(:relic_id => [id] + descendant_ids).order("relic_id ASC")
  end

  def all_links
    Link.where(:relic_id => [id] + descendant_ids).order("relic_id ASC, position ASC")
  end

  def all_events
    Event.where(:relic_id => [id] + descendant_ids).order("date_start ASC")
  end

  def polish_relic
    self.class == Relic
  end

  def foreign_relic?
    country_code.upcase != 'PL'
  end

  def latitude=(value)
    super
    if latitude_changed?
      self.geocoded = true
    end
  end

  def longitude=(value)
    super
    if longitude_changed?
      self.geocoded = true
    end
  end

  def place_with_address
    "#{place_full_name}, #{street_normalized}"
  end

  def parse_date
    self.date_start, self.date_end = DateParser.new(dating_of_obj).results
  end

  def parent_id=(value)
    if value.present?
      self.parent = Relic.find(value)
    else
      self.parent = nil
    end
  end

  def up_id
    place_id
  end

  def up
    place
  end

  def to_param
    slug = [(fplace || place.name), identification].join('-').gsub(/\d+/, '').parameterize
    [id, slug] * '-'
  end

  def state_name
    I18n.t("activerecord.attributes.relic.states.#{state}")
  end

  def existance_name
    I18n.t("activerecord.attributes.relic.existences.#{existence}")
  end

  def build_finished?
    self.build_state == 'finish_step'
  end
end
