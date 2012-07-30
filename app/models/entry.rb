class Entry < ActiveRecord::Base
  belongs_to :relic
  belongs_to :user

  attr_accessible :body, :relic_id, :title, :user_id
end
