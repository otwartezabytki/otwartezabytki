json.(relic,
  :id,
  :nid_id,
  :identification,
  :common_name,
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

json.events relic.events do |e|
  json.id e.id
  json.date e.date
  json.name e.name
  json.photo_id e.photo_id
end

json.entries relic.entries, :id, :title, :body
json.links relic.links, :id, :name, :url, :category, :kind

json.documents relic.documents do |d|
  json.id d.id
  json.name d.name
  json.description d.description
  json.url d.file.try(:url)
end

json.alerts relic.alerts do |a|
  json.id a.id
  json.url a.file.try(:url)
  json.author a.author
  json.date_taken a.date_taken
  json.description a.description
  json.state a.state
end

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
