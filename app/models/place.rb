# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: places
#
#  id                 :integer          not null, primary key
#  commune_id         :integer
#  name               :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  sym                :string(255)
#  from_teryt         :boolean          default(TRUE)
#  custom             :boolean          default(FALSE)
#  virtual_commune_id :string(255)
#  latitude           :float
#  longitude          :float
#

# -*- encoding : utf-8 -*-
class Place < ActiveRecord::Base
  include GeocodeViewport
  include Relic::BoundingBox

  attr_accessible :id, :name, :commune_id, :sym, :from_teryt
  belongs_to :commune
  has_many :relics, :dependent => :destroy

  validates :name, :presence => true

  scope :not_custom, where(:custom => false)
  scope :search, lambda {|term| where("name ILIKE ?", "%#{term}%") }

  attr_accessor :facet_count

  def virtual_commune_id
    self[:virtual_commune_id] || self[:commune_id]
  end

  def location_string
    ['pl', commune.district.voivodeship_id, commune.district_id, virtual_commune_id, id].join('-')
  end

  def location_names
    [commune.district.voivodeship.name, commune.district.name, commune.name, name]
  end

  def address
    location_names.unshift('Polska').join(', ')
  end

  def conditional_geocode!
    unless latitude?
      geocode
      save!
    end
  end
  class << self
    def find_by_position(lat, lng)
      return nil unless lat and lng
      find_by_type = lambda do |data, *type|
        attr = ['short_name', 'long_name'].include?(type.last) ? type.pop : 'long_name'
        (data['address_components'].find { |c| type.all? { |t| c['types'].include?(t) } } || {})[attr]
      end
      geo = Geocoder.search([lat, lng].map{|l| l.gsub(',','.').to_f}.join(', ')).find do |result|
        # Rails.logger.info "geo: #{result.inspect}"
        find_by_type.call(result.data, 'country', 'political').present?
      end
      if geo
        data = geo.data
        location = {
          :foreign      => false,
          :street       => [find_by_type.call(data, 'route'), find_by_type.call(data, 'street_number')].compact.join(' '),
          :place        => find_by_type.call(data, 'locality', 'political'),
          :commune      => find_by_type.call(data, 'administrative_area_level_3', 'political'),
          :district     => find_by_type.call(data, 'administrative_area_level_2', 'political'),
          :voivodeship  => find_by_type.call(data, 'administrative_area_level_1', 'political'),
          :country      => find_by_type.call(data, 'country', 'political'),
          :country_code => find_by_type.call(data, 'country', 'political', 'short_name'),
          :latitude     => lat,
          :longitude    => lng
        }
        if location[:country] != 'Polska'
          location[:foreign] = true
          return location
        end

        conds = [ "LOWER(places.name) = LOWER(?)", "LOWER(communes.name) = LOWER(?)", "LOWER(districts.name) = LOWER(?)", "LOWER(voivodeships.name) = LOWER(?)" ]
        location[:objs] = {}

        location[:objs][:place] = Place.joins(:commune => { :district => :voivodeship}).where([
          conds.join(' AND '),
          location[:place],
          location[:commune],
          location[:district],
          location[:voivodeship]
        ]).first

        if location[:objs][:place]
          location[:objs].merge!({
            :commune      => location[:objs][:place].commune,
            :district     => location[:objs][:place].commune.district,
            :voivodeship  => location[:objs][:place].commune.district.voivodeship
          })
        else
          # location[:objs][:commune] = Commune.joins(:district => :voivodeship).where([
          #   conds.drop(1).join(' AND '),
          #   location[:commune],
          #   location[:district],
          #   location[:voivodeship]
          # ]).first

          # location[:objs][:district] = District.joins(:voivodeship).where([
          #   conds.drop(2).join(' AND '),
          #   location[:district],
          #   location[:voivodeship]
          # ]).first

          # location[:objs][:voivodeship] = Voivodeship.where([
          #   conds.drop(3).join(' AND '),
          #   location[:voivodeship]
          # ]).first
        end
        location
      end
    end
  end

  def full_name
    name
  end

  def up_id
    commune_id
  end

  def up
    commune
  end

  def bounding_box
    right_up_lat, right_up_lng, left_down_lat, left_down_lng = viewport.split('|').map{ |e| e.split(',') }.flatten

    [{lat: right_up_lat, lng: left_down_lng}, { lat: left_down_lat, lng: right_up_lng }]
  end

  def self.visible_from
    5
  end
end
