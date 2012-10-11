# -*- encoding : utf-8 -*-
# require bounding_box_size method on class
module Relic::BoundingBox

  extend ActiveSupport::Concern

  def bounding_box
    equidistance_bounding_box(latitude, longitude, self.class.visible_from)
  end

  module ClassMethods
    def visible_from
      raise "Please overwrite visible_from method with bounding box width."
    end
  end

  private

  def equidistance_bounding_box(latitude, longitude, side)

    latitude_radians = (latitude / 180.0) * Math::PI
    longitude_radians = (longitude / 180.0) * Math::PI

    half_side = side / 2.0

    radius = 6371.01 # of the Earth
    pradius = radius * Math.cos(latitude_radians)

    lat_min = latitude_radians - half_side / radius
    lat_max = latitude_radians + half_side / radius
    lon_min = longitude_radians - half_side / pradius
    lon_max = longitude_radians + half_side / pradius

    rad2deg = lambda { |radians| radians / Math::PI * 180.0  }

    return [
      { lat: rad2deg[lat_max], lng: rad2deg[lon_min] },
      { lat: rad2deg[lat_min], lng: rad2deg[lon_max] }
    ]
  end
end
