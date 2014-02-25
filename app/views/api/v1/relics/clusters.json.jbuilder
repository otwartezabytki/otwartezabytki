if params[:short]
  json.meta do |json|
    json.total_pages @relics.total_pages
    json.current_page @relics.current_page
    json.relics_count @relics.size
    json.total_count @relics.total_count
  end

  json.relics @relics.map{ |r| relic_to_widget_data_short(r) }
else
  json.meta do |json|
    json.total_pages @relics.total_pages
    json.current_page @relics.current_page
    json.relics_count @relics.size
    json.total_count @relics.total_count
  end

  json.relics @relics.map{ |r| relic_to_widget_data(r, false) }
  json.clusters leafs_of(@relics.polish_facets_tree).map{ |f| facet_to_marker(f) }
end
