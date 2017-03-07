# -*- encoding : utf-8 -*-
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
#  description      :text
#  alternate_text   :string(255)
#

class Photo < ActiveRecord::Base
  include StateExt
  default_scope { order('photos.relic_id, photos.position ASC') }

  belongs_to :relic
  belongs_to :user
  has_many :events

  attr_accessible :author, :file, :date_taken, :description, :alternate_text, :position, :as => [:default, :admin]
  attr_accessible :relic_id, :user_id, :as => :admin

  acts_as_list :scope => :relic, add_new_at: :bottom

  validates :file, :relic, :user, :presence => true
  validates :file, :file_size => { :maximum => 2.megabytes.to_i }
  validates :author, :date_taken, :presence => true, :unless => :initialized?

  mount_uploader :file, PhotoUploader
  has_paper_trail :skip => [:created_at, :updated_at, :versions]
  #
  # def self.one_after(photo_id)
  #   where('id > ?', photo_id).order('id ASC').limit(1).first
  # end
  #
  # def self.one_after?(photo_id, photo_list)
  #   photo_index = photo_list.index{ |item| item.id == photo_id}
  #   photo_after = photo_list[photo_index + 1]
  #   if  photo_after == 0 || photo_after == nil
  #     return false
  #   end
  #   true
  # end
  #
  # def self.one_before(photo_id, photo_list)
  #   photo_index = photo_list.index{ |item| item.id == photo_id}
  #   photo_list[photo_index - 1]
  #   # where('id < ?', photo_id).order('id DESC').limit(1).first
  # end
  # def self.one_before?(photo_id, photo_list)
  #   photo_index = photo_list.index{ |item| item.id == photo_id}
  #   photo_before = photo_list[photo_index - 1]
  #   if  photo_before == 0 || photo_before == nil
  #     return false
  #   end
  #   true
  # end

  def as_json(options)
    {
      :id => id,
      :relic_id => relic_id,
      :author => author,
      :date_taken => date_taken,
      :alternate_text => alternate_text,
      :file => file.as_json(options)[:file],
      :file_full_width => file_full_width,
      :description => description,
      :position => position
    }
  end
end
