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
end
