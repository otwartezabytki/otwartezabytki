class UserRelic < ActiveRecord::Base
  belongs_to :user
  belongs_to :relic
end
