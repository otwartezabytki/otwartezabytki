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
  Kinds = [
    "OZ", # part of relic group's
    "ZZ", # nested relic group's
    "SA", # single relic
    "ZE"  # relic group's
  ]

  has_ancestry

  has_one    :original_relic
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
                  :geocoded, :build_state, :parent_id, :common_name, :kind, :as => [:default, :admin]

  attr_accessible :ancestry, :register_number, :approved, :state, :existence, :as => :admin

  accepts_nested_attributes_for :photos, :documents, :entries, :links, :events, :allow_destroy => true

  include PlaceCaching
  include Validations
  include EsConfig

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
    self.existence = 'social' unless ['social', 'archived'].include?(self.existence)
  end

  # prevents from keeping track of blank changes
  before_save do
    [:common_name, :description, :documents_info, :links_info].each do |a|
      if changed.include?(a.to_s)
        read_attribute(a).present? || write_attribute(a, nil)
      end
    end
  end

  validates :state, :inclusion => { :in => States }, :if => :state_changed?
  validates :existence, :inclusion => { :in => Existences }, :if => :existence_changed?
  validates :kind, :inclusion => { :in => Kinds }, :if => :kind_changed?

  # versioning
  has_paper_trail :skip => [:updated_at, :created_at, :user_id, :build_state, :kind, :date_start, :date_end,
    :type, :commune_id, :district_id, :voivodeship_id, :geocoded, :reason]

  class << self
    def random_filled
      conds = { :state => 'filled' }
      relics_count = self.where(conds).count
      if relics_count.zero?
        conds[:state] = 'checked'
        relics_count = self.where(conds).count
      end
      self.where(conds).offset(rand(relics_count)).first || self.offset(rand(self.count)).first
    end
  end

  def street(normalized = false)
    return self[:street] unless normalized
    street_normalized = self[:street].to_s.split('/').first.to_s
    street_normalized.gsub!(/[^a-zA-Z0-9_]+[\d]+$/i, '')
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
    @main_photo = (self.all_photos.order('CASE(photos.main) WHEN TRUE THEN 0 ELSE 1 END').first || Photo.new)
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

  def place_with_address(norm = false)
    [place_full_name, street(norm)].reject(&:blank?) * ", "
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

  def existence_name
    I18n.t("activerecord.attributes.relic.existences.#{existence}")
  end

  def build_finished?
    self.build_state == 'finish_step'
  end

  def is_group?
    return 'ZE' == kind if new_record?
    'ZE' == kind or (is_root? and has_children?)
  end

  def revisions
    versions.reorder('created_at DESC').limit(3)
  end

end
