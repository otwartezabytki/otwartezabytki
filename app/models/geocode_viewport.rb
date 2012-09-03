module GeocodeViewport
  extend ActiveSupport::Concern

  included do
    geocoded_by :address do |obj,results|
      if geo = results.first
        obj.latitude  = geo.latitude
        obj.longitude = geo.longitude
        viewport = geo.data.get_deep('geometry', 'viewport')
        # viewport
        # ne|sw => lat,lng|lat,lng
        if viewport.present?
          obj.viewport = [viewport['northeast'].values.join(','), viewport['southwest'].values.join(',')].join('|')
        end
      end
    end
  end

  def default_zoom
    east = viewport.split('|').first.split(',').last.to_f
    west = viewport.split('|').last.split(',').last.to_f
    angle = east - west
    angle += 360.0 if angle < 0.0
    zoom = (Math.log(360.0 / angle) / Math.log(2)).floor

    [self.class.zoom_range.to_a.last, [self.class.zoom_range.to_a.first, zoom].max, zoom].min
  end

end