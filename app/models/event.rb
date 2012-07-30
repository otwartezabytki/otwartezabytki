class Event < ActiveRecord::Base
  belongs_to :relic
  belongs_to :user

  attr_accessible :date, :date_end, :date_start, :name, :relic_id, :user_id
end
