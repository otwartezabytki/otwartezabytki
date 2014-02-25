# -*- encoding : utf-8 -*-
module WidgetsHelper

  # Converts facet from search results to Hash
  # containing data relevant to map search widget
  def facet_to_marker(place)
    {
      :type => place.class.name.underscore,
      :id => place.class == Commune ? place.virtual_id : place.id.to_s,
      :facet_count => place.facet_count,
      :latitude => place.latitude,
      :longitude => place.longitude,
      :bounding_box => place.bounding_box
    }
  end

  # Converts Relic object to Hash
  # containing data relevant to map search widget
  def relic_to_widget_data(relic, with_photo = true)
    data = {
      :id => relic.id,
      :latitude => relic.latitude,
      :longitude => relic.longitude,
      :identification => relic.identification,
      :street => relic.street,
      :place => relic.place.name
    }
    data[:main_photo] = relic.main_photo if with_photo
    data
  end

  def relic_to_widget_data_short(relic)
    [relic.id, relic.latitude, relic.longitude]
  end

  def route_type_collection
    ['walking', 'bicycling', 'driving'].map do |type|
      [I18n.t("views.widgets.route_types.#{type}"), type]
    end
  end
end
