leafs = leafs_of(@relics.polish_facets_tree)

if leafs.map(&:facet_count).inject(0, &:+) > 100
  json.relics []
  json.clusters leafs.map{ |f| facet_to_marker(f) }
else
  json.relics @relics.map{ |r| relic_to_widget_data(r) }
  json.clusters []
end
