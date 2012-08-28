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

end