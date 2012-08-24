json.meta do |json|
  json.total_pages @places.num_pages
  json.current_page @places.current_page
  json.places_count @places.size
  json.total_count @places.total_count
end

json.places do |json|
  json.array!(@places) do |json, place|
    json.partial! "api/v1/places/place", :place => place
  end
end
