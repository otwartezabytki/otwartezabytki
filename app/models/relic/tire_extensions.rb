module Tire
  module Results
    module Collection
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
        (self.facets[name].try(:[], 'terms') || []).tap do |terms|
          terms.sort_by!{ |t| Unicode.downcase(t['term']) } if unicode_order
          terms.map! do |t|
            id = t['term'].split('_').last
            klass = name.classify.constantize
            t['obj'] = Rails.cache.fetch("#{name.classify.downcase}_#{id}", :expires_in => 1.day) do
              klass.find(id.split(':').first)
            end
            t
          end if load
        end
      end

      def overall_count
        facets['overall']['total'].to_i rescue 0
      end
    end
  end
end

module Tire
  module Results
    module Item
      def corrected?(user = nil)
        @is_corrected ||= {}
        return @is_corrected[user.try(:id)] if @is_corrected[user.try(:id)]
        @is_corrected[user.try(:id)] = (!!user and user.corrected_relic_ids.include?(self[:id].to_i)) or self[:edit_count] > 2
      end
    end
  end
end
