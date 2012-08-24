json.(relic, :id, :categories, :country, :description, :existance, :identification, :state, :street, :tags, :type)

if params[:include_descendants]
  json.descendants do |json|
    json.array!(relic.descendants) do |json, r|
      json.partial! "api/v1/relics/relic", :relic => r
    end
  end
else
  json.descendants relic.descendant_ids
end

json.commune do |json|
  json.partial! "api/v1/communes/commune", :commune => relic.commune
end

json.district do |json|
  json.partial! "api/v1/districts/district", :district => relic.district
end

json.voivodeship do |json|
  json.partial! "api/v1/voivodeships/voivodeship", :voivodeship => relic.voivodeship
end

json.place do |json|
  json.partial! "api/v1/places/place", :place => relic.place
end

