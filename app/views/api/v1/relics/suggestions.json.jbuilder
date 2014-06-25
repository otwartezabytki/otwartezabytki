json.meta do |json|
  json.total_pages @relics.total_pages
  json.current_page @relics.current_page
  json.relics_count @relics.size
  json.total_count @relics.total_count
end

json.relics @relics.map{ |r| relic_to_widget_data(r, false) }
