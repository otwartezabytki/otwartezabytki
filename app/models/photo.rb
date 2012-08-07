# == Schema Information
#
# Table name: photos
#
#  id         :integer          not null, primary key
#  relic_id   :integer
#  user_id    :integer
#  name       :string(255)
#  author     :string(255)
#  file       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Photo < ActiveRecord::Base
  belongs_to :relic
  belongs_to :user

  attr_accessible :author, :name, :relic_id, :user_id

  mount_uploader :file, PhotoUploader
end
