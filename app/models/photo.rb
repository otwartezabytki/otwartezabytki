# == Schema Information
#
# Table name: photos
#
#  id               :integer          not null, primary key
#  relic_id         :integer
#  user_id          :integer
#  name             :string(255)
#  author           :string(255)
#  file             :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  main             :boolean
#  date_taken       :string(255)
#  file_full_width  :integer
#  file_full_height :integer
#

class Photo < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  belongs_to :relic
  belongs_to :user

  attr_accessible :author, :file, :date_taken, :as => [:default, :admin]
  attr_accessible :relic_id, :user_id, :as => :admin

  mount_uploader :file, PhotoUploader

  validates :file, :relic, :user, :presence => true
  validates :author, :date_taken, :presence => true, :unless => :new_record?

  has_paper_trail

  def self.one_after(photo_id)
    where('id > ?', photo_id).order('id ASC').limit(1).first
  end

  def self.one_before(photo_id)
    where('id < ?', photo_id).order('id DESC').limit(1).first
  end
end
