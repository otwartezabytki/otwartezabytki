# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  relic_id   :integer
#  user_id    :integer
#  name       :string(255)
#  date       :string(255)
#  date_start :date
#  date_end   :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Event < ActiveRecord::Base
  belongs_to :relic
  belongs_to :user

  attr_accessible :date, :date_end, :date_start, :name, :relic_id, :user, :position

  acts_as_list :scope => :relic

  validates :relic, :user, :name, :date, :presence => true

  include CanCan::Authorization
end
