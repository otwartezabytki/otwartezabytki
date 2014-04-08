# -*- encoding : utf-8 -*-
module AdministrativeHelper
  def voivodeship_collection
    Voivodeship.order(:name).map { |v| [v.name, v.id] }
  end

  def district_collection
    @voivodeship.districts.order(:name).map { |v| [v.name, v.id] }
  end

  def commune_collection
    @district.communes.order(:name).map { |v| [v.name, v.virtual_id] }.uniq
  end

  def place_collection
    @commune.places.order(:name).map { |v| [v.name, v.id] }
  end

  def voivodeships_for_map
    return @voivodeships_for_map if defined?(@voivodeships_for_map)
    voivodeships = Voivodeship.order('id ASC')
    stats = Relic.where(voivodeship_id: voivodeships.map(&:id)).
      group(:voivodeship_id, :state).
      count.
      inject({}) do |result, (k, v)|
        result[k[0]] ||= {}
        result[k[0]][k[1]] = v
        result
      end
    @voivodeships_for_map = voivodeships.map do |voivodeship|
      obj = OpenStruct.new(
        id:    voivodeship.id,
        name:  voivodeship.name,
        stats: stats[voivodeship.id]
      )
      def obj.stats_for(val)
        stats[val] || 0
      end
      obj
    end
    @voivodeships_for_map
  end
end
