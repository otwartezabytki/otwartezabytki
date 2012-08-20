# == Schema Information
#
# Table name: seen_relics
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  relic_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SeenRelic < ActiveRecord::Base
  belongs_to :relic
  belongs_to :user
  attr_accessible :relic_id, :user_id
end
