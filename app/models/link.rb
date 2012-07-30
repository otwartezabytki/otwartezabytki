class Link < ActiveRecord::Base
  belongs_to :relic
  belongs_to :user

  attr_accessible :name, :relic_id, :url, :user_id
end
