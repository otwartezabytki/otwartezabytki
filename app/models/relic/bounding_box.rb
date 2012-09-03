# require bounding_box_size method on class
module Relic::BoundingBox

  extend ActiveSupport::Concern

  def bounding_box
    upper_left = {lat: (latitude + self.class.visible_from / 2.0).round(7), lng: (longitude + self.class.visible_from / 2.0).round(7)}
    lower_right = {lat: (latitude - self.class.visible_from / 2.0).round(7), lng: (longitude - self.class.visible_from / 2.0).round(7)}
    [upper_left, lower_right]
  end

  module ClassMethods
    def visible_from
      raise "Please overwrite visible_from method with bounding box width."
    end
  end
end