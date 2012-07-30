class Alert < ActiveRecord::Base
  belongs_to :relic
  belongs_to :user

  attr_accessible :description, :kind, :relic_id, :user_id
end
