# == Schema Information
#
# Table name: alerts
#
#  id          :integer          not null, primary key
#  relic_id    :integer
#  user_id     :integer
#  kind        :string(255)
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Alert < ActiveRecord::Base
  belongs_to :relic
  belongs_to :user

  attr_accessible :description, :kind, :relic_id, :user_id
end
