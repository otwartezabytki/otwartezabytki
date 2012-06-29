class SearchTerm < ActiveRecord::Base
  attr_accessible :keyword

  class << self
    def store(keyword)
      keyword = keyword.to_s.strip
      return false if keyword.blank? or keyword == '*'
      st = self.where(:keyword => keyword).first
      Rails.logger.info "key: #{keyword}"
      if st
        self.increment_counter(:count, st.id)
      else
        self.create(:keyword => keyword)
      end
    end
  end

end
