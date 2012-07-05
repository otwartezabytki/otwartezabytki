class SeenRelic < ActiveRecord::Base
  belongs_to :relic
  belongs_to :user
  attr_accessible :relic_id, :user_id
end
