# == Schema Information
#
# Table name: links
#
#  id         :integer          not null, primary key
#  relic_id   :integer
#  user_id    :integer
#  name       :string(255)
#  url        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Link < ActiveRecord::Base
  belongs_to :relic
  belongs_to :user

  attr_accessible :name, :relic_id, :url, :user_id
end
