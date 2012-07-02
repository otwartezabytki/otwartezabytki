# -*- encoding : utf-8 -*-
module ApplicationHelper

  def next_relic_url_for(user)
    edit_relic_path(Relic.next_for(user).id)
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
			range[3] = Suggestion.where(["date_part('hour', suggestions.created_at) BETWEEN ? AND ?", a, b-1]).count
		end

		ranges.reject! {|e| e[3] == 0 }
    ranges.sort_by! {|e| e[3] }

		all = Suggestion.count

		ranges.each do |range|
			range[4] = range[3] * 100 / all
		end

		[ranges.shift, ranges.last] # use .shift so .last will not be the same in case of just one non-zero range
	end

	def relics_statistics
		[Relic.count] + [1,2,3].map {|i| Relic.where(["edit_count >= ?", i]).count }
	end

	def random_search_suggestions
		types = SuggestedType.order("RANDOM()").map {|e| e.name }
		places = Relic.select("place_id, COUNT(id) as cnt").group(:place_id).having("COUNT(id) > 5").order("RANDOM()").limit(4).includes(:place).map {|r| r.place.name }
		suggestions = []

		first = types.shift
		count = Relic.search(:q1 => first).total_count
		suggestions[0] = link_to "#{first} (#{count})", relics_path(:q1 => first)

		first = places.shift
		count = Relic.search(:q1 => first).total_count
		suggestions[2] = link_to "#{first} (#{count})", relics_path(:q1 => first)

		types.each do |type|
			places.each do |place|
				q = type + " " + place
				count = Relic.search(:q1 => q).total_count
				if count > 0
					suggestions[1] = link_to "#{q} (#{count})", relics_path(:q1 => q)
					break
				end
			end
		end

		suggestions.join(", ").html_safe
	end

end
