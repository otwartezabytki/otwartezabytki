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
  attr_accessible :id, :name, :commune_id, :sym, :from_teryt
  belongs_to :commune
  has_many :relics, :dependent => :destroy

  validates :name, :presence => true

  scope :not_custom, where(:custom => false)
  scope :search, lambda {|term| where("name ILIKE ?", "%#{term}%") }

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
      find_by_type = lambda do |data, *type|
        (data['address_components'].find { |c| type.all? { |t| c['types'].include?(t) } } || {})['long_name']
      end
      geo = Geocoder.search([lat, lng].map{|l| l.gsub(',','.').to_f}.join(', ')).find do |result|
        find_by_type.call(result.data, 'locality', 'political').present?
      end
      if geo
        data = geo.data
        location = {
          :street       => [find_by_type.call(data, 'route'), find_by_type.call(data, 'street_number')].compact.join(' '),
          :place        => find_by_type.call(data, 'locality', 'political'),
          :commune      => find_by_type.call(data, 'administrative_area_level_3', 'political'),
          :district     => find_by_type.call(data, 'administrative_area_level_2', 'political'),
          :voivodeship  => find_by_type.call(data, 'administrative_area_level_1', 'political'),
          :country      => find_by_type.call(data, 'country', 'political')
        }
        return location if location[:country] != 'Polska'

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

end
