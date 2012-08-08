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

  attr_accessible :relic_id, :user_id, :author, :file

  mount_uploader :file, PhotoUploader

  validates :file, :relic, :user, :presence => true
end
