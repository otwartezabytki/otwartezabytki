# data: Hash
# relic: Relic

[:id, :categories, :country, :description, :existance, :has_description, :has_photos,
:has_round_date, :highlight, :identification, :state, :street, :tags, :type].each do |key|
  json.__send__(key, data[key])
end

if params[:include_descendants]
  json.descendants do |json|
    json.array!(relic.descendants) do |json, r|
      json.partial! "api/v1/relics/relic", :data => r.to_indexed_hash, :relic => r
    end
  end
else
  json.descendants data[:descendants].map {|e| e[:id]}
end

json.commune do |json|
  json.partial! "api/v1/communes/commune", :commune => data[:commune]
end

json.district do |json|
  json.partial! "api/v1/districts/district", :district => data[:district]
end

json.voivodeship do |json|
  json.partial! "api/v1/voivodeships/voivodeship", :voivodeship => data[:voivodeship]
end

json.place do |json|
  json.partial! "api/v1/places/place", :place => data[:place].to_hash.merge(
    :full_name => data[:place_full_name],
    :with_address => data[:place_with_address]
  )
end

