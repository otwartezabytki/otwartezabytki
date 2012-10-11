# -*- encoding : utf-8 -*-
# this module caches location fields for quick access
module Relic::PlaceCaching
  extend ActiveSupport::Concern

  included do
    belongs_to :commune
    belongs_to :district
    belongs_to :voivodeship

    before_save :cache_location_fields, :if => :place_id_changed?

    attr_protected :commune, :district, :voivodeship, :commune_id, :district_id, :voivodeship_id
  end

  def place=(value)
    super
    cache_location_fields
  end

  def place_id=(value)
    self[:place_id] = value
    cache_location_fields
  end

  def cache_location_fields
    if self.place
      self.place.conditional_geocode!
      self.latitude       ||= self.place.latitude
      self.longitude      ||= self.place.longitude
      self.commune_id     = self.place.commune_id
      self.district_id    = self.place.commune.district_id
      self.voivodeship_id = self.place.commune.district.voivodeship_id
    end
  end

  def commune_id
    cache_location_fields unless self[:commune_id]
    self[:commune_id]
  end

  def district_id
    cache_location_fields unless self[:district_id]
    self[:district_id]
  end

  def voivodeship_id
    cache_location_fields unless self[:voivodeship_id]
    self[:voivodeship_id]
  end

  def commune
    Commune.cached(:find, :with => commune_id) if commune_id
  end

  def district
    District.cached(:find, :with => district_id) if district_id
  end

  def voivodeship
    Voivodeship.cached(:find, :with => voivodeship_id) if voivodeship_id
  end

  def place
    Place.cached(:find, :with => place_id) if place_id
  end
end
