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
# Indexes
#
#  index_seen_relics_on_relic_id              (relic_id)
#  index_seen_relics_on_user_id               (user_id)
#  index_seen_relics_on_user_id_and_relic_id  (user_id,relic_id)
#

class SeenRelic < ActiveRecord::Base
  belongs_to :relic
  belongs_to :user
  attr_accessible :relic_id, :user_id
end
