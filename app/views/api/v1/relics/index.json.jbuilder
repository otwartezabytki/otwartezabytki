json.meta do |json|
  json.total_pages @relics.total_pages
  json.current_page @relics.current_page
  json.relics_count @relics.size
  json.total_count @relics.total_count
end

json.relics do |json|
  json.array!(@relics) do |json, relic|
    json.partial! "api/v1/relics/relic", :relic => relic
  end
end

json.clusters leafs_of(@relics.polish_facets_tree).map{ |f| facet_to_marker(f) }
