json.(relic,
  :id,
  :nid_id,
  :identification,
  :description,
  :categories,
  :state,
  :register_number,
  :dating_of_obj,
  :street,
  :latitude,
  :longitude,
  :tags,
  :country_code,
  :fprovince,
  :fplace,
  :documents_info,
  :links_info,
  :main_photo
)

if params[:include_descendants]
  json.descendants do |json|
    json.array!(relic.descendants) do |json, r|
      json.partial! "api/v1/relics/relic", relic: r, params: params
    end
  end
else
  json.descendants relic.descendant_ids
end

json.photos relic.photos

if relic.place
  json.place_id relic.place.id
  json.place_name relic.place.name
  json.commune_name relic.place.commune.name
  json.district_name relic.place.commune.district.name
  json.voivodeship_name relic.place.commune.district.voivodeship.name
end
