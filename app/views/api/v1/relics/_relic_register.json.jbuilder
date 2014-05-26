
needed_attributes = [:id, :nid_id, :identification, :common_name, :state,
    :register_number, :dating_of_obj, :street, :latitude, :longitude,]
    
needed_attributes += [:country_code, :fprovince, :fplace] if relic.respond_to?(:country_code)

json.(relic, *needed_attributes)    

if params[:include_descendants]
  json.descendants do |json|
    json.array!(relic.descendants) do |json, r|
      json.partial! "api/v1/relics/relic_register", relic: r, params: params
    end
  end
else
  json.descendants relic.descendant_ids
end

if relic.place
  json.place_id relic.place.id
  json.place_name relic.place.name
  json.commune_name relic.place.commune.name
  json.district_name relic.place.commune.district.name
  json.voivodeship_name relic.place.commune.district.voivodeship.name
end
