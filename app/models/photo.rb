class Photo < ActiveRecord::Base
  belongs_to :relic
  belongs_to :user

  attr_accessible :author, :name, :relic_id, :user_id

  mount_uploader :file, PhotoUploader
end
