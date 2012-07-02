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
      self.commune_id = self.place.commune.id
      self.district_id = self.place.commune.district.id
      self.voivodeship_id = self.place.commune.district.voivodeship.id
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
    cache_location_fields unless self[:commune_id]

    if self[:commune_id]
      Rails.cache.fetch("commune_#{self[:commune_id]}", :expires_in => 1.day) do
        super
      end
    else
      nil
    end
  end

  def district
    cache_location_fields unless self[:district_id]

    if self[:district_id]
      Rails.cache.fetch("district_#{self[:district_id]}", :expires_in => 1.day) do
        super
      end
    else
      nil
    end
  end

  def voivodeship
    cache_location_fields unless self[:voivodeship_id]

    if self[:voivodeship_id]
      Rails.cache.fetch("voivodeship_#{self[:voivodeship_id]}", :expires_in => 1.day) do
        super
      end
    else
      nil
    end

  end

  def place

    if self[:place_id]
      Rails.cache.fetch("place_#{self[:place_id]}", :expires_in => 1.day) do
        super
      end
    else
      nil
    end

  end
end