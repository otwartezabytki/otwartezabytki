# -*- encoding : utf-8 -*-
module ApplicationHelper

  def next_relic_url_for(user)
    edit_relic_path(Relic.next_for(user, session[:search_params]))
  end

  def users_statistics
    all = User.count
    registered = User.where("username IS NOT NULL").count
    [all, registered, all-registered]
  end

  def users_activity_statistics
    ranges = [
      [5, 8, "przed śniadaniem"],
      [8, 17, "w godzinach pracy"],
      [17, 20, "przed kolacją"],
      [20, 0, "po wieczornym wydaniu wiadomości"],
      [0, 5, "przez sen :)"]
    ]

    ranges.each do |range|
      a,b = range[0], range[1]-1
      b += 24 if b < 0 # 0 - 1 = -1 => -1 + 24 = 23
      range[3] = Suggestion.roots.where(["date_part('hour', suggestions.created_at) BETWEEN ? AND ?", a, b-1]).count
    end

    ranges.reject! {|e| e[3] == 0 }
    ranges.sort_by! {|e| e[3] }

    all = Suggestion.roots.count

    ranges.each do |range|
      range[4] = range[3] * 100 / all
    end

    [ranges.pop, ranges.first].reverse
  end

  def relics_statistics
    [Relic.roots.count] + [1,2,3].map {|i| Relic.roots.where(["edit_count >= ?", i]).count }
  end

  def random_search_suggestions
    types = SuggestedType.order("RANDOM()").map {|e| e.name }
    places = Relic.roots.select("place_id, COUNT(id) as cnt").group(:place_id).having("COUNT(id) > 5").order("RANDOM()").limit(5).includes(:place).map {|r| r.place.name }
    suggestions = []

    first = types.shift
    count = Relic.search(:q1 => first).total_count
    suggestions[0] = [first, count]

    first = places.shift
    count = Relic.search(:q1 => first).total_count
    suggestions[2] = [first, count]

    types.each do |type|
      places.each do |place|
        q = type + " " + place
        count = Relic.search(:q1 => q).total_count
        if count > 0
          suggestions[1] = [q, count]
          break
        end
      end
    end

    suggestions.map do |label, count|
      link_to "#{label} <span>(#{count})</span>".html_safe, relics_path(:q1 => label)
    end.join(", ").html_safe
  end

	def link_to_facet obj, location, deep, &block
		selected 	= location[deep] == obj.id.to_s
    label 		= "#{obj.name} <span>#{obj.count}</span>".html_safe
    link 			= link_to label, relics_path(search_params.merge(:location => (location.first(deep) << obj.id).join('-')))
    output = []
		if selected
			output << content_tag(:div, :class => 'selected') do
				if location.size == (deep + 1)
        	content_tag(:p, label)
      	else
       		link
       	end
      end
    else
    	output <<  link
    end
    if selected and block_given?
    	output.join.html_safe + capture(&block)
    else
    	output.join.html_safe
    end
	end

end
