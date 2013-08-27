leafs = leafs_of(@relics.polish_facets_tree)

json.relics @relics.map{ |r| relic_to_widget_data(r, false) }
json.clusters leafs.map{ |f| facet_to_marker(f) }
