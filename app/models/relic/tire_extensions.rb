module Tire
  module Results
    class Collection
      def highlighted_tags
        return @highlighted_tags if defined? @highlighted_tags
        @highlighted_tags = @response['hits']['hits'].inject([]) do |m, h|
          m << h['highlight'].values.join.scan(/<em>(.*?)<\/em>/) if h['highlight']
          m
        end.flatten.uniq.select{|w| w.size > 1}.sort_by{|w| -w.size}.map{ |t| Unicode.downcase(t) }
      end

      def correct_count
        return @correct_count if defined? @correct_count
        @correct_count = self.facets['corrected']['terms'].select {|a| a['term'] == 1}.first['count'] rescue 0
      end

      def incorrect_count
        return @incorrect_count if defined? @incorrect_count
        @incorrect_count = self.facets['corrected']['terms'].select {|a| a['term'] == 0}.first['count'] rescue 0
      end

      def terms name, unicode_order = false, load = false
        ((self.facets || {}).get_deep(name, 'terms') || []).tap do |terms|
          terms.sort_by!{ |t| Unicode.downcase(t['term']) } if unicode_order
          terms.map! do |t|
            id = t['term'].split('_').last
            name = 'place' if name == 'streets'
            klass = name.classify.constantize
            t['obj'] = klass.cached(:find, :with => id.split(':').first)
            t
          end if load
        end
      end

      def count name = nil
        if name.present?
          facets[name]['total'].to_i rescue 0
        else
          super
        end
      end

      def widget_facets(name)
        terms(name, true, true).map do |result|
          result["obj"].tap { |o| o.facet_count = result["count"] }
        end
      end

      def polish_facets_tree(level = nil)
        return @polish_facets_tree if @polish_facets_tree

        levels = ["countries", "voivodeships", "districts", "communes", "places",  nil]

        if level.present?
          next_level = levels.each_cons(2).to_a.find{ |key| level == key.first }.last
        else
          level, next_level = levels.each_cons(2).to_a.find{ |key| facets.keys.include?(key.first) }
        end

        result = Hash[widget_facets(level).map{ |first| [first, Hash.new] }]

        if next_level.present?
          polish_facets_tree(next_level).each do |key, value|
            if obj = result.keys.find{ |location| location.id == key.up_id }
              result[obj][key] = value
            end
          end
        end

        @polish_facets_tree = result
      end
    end
  end
end

module Tire
  module Results
    class Item
      def slug
        self[:slug] || self[:id]
      end
      def corrected?(user = nil)
        return false
        @is_corrected ||= {}
        return @is_corrected[user.try(:id)] if @is_corrected[user.try(:id)]
        @is_corrected[user.try(:id)] = (!!user and user.corrected_relic_ids.include?(self[:id].to_i)) or self[:edit_count] > 2
      end
    end
  end
end
