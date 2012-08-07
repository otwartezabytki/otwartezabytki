# == Schema Information
#
# Table name: search_terms
#
#  id         :integer          not null, primary key
#  keyword    :string(255)
#  count      :integer          default(1)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_search_terms_on_keyword  (keyword)
#

class SearchTerm < ActiveRecord::Base
  attr_accessible :keyword

  class << self
    def store(keyword)
      keyword = keyword.to_s.strip
      return false if keyword.blank? or keyword == '*'
      st = self.where(:keyword => keyword).first
      if st
        self.increment_counter(:count, st.id)
      else
        self.create(:keyword => keyword)
      end
    end
  end

end
