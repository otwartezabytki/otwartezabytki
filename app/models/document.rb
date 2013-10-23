# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: documents
#
#  id          :integer          not null, primary key
#  relic_id    :integer
#  user_id     :integer
#  name        :string(255)
#  size        :integer
#  mime        :string(255)
#  file        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :string(255)
#  position    :integer
#

class Document < ActiveRecord::Base
  default_scope { order('documents.id ASC') }

  belongs_to :relic
  belongs_to :user

  attr_accessible :name, :description, :file, :as => [:default, :admin]
  attr_accessible :relic_id, :user_id, :as => :admin

  mount_uploader :file, DocumentUploader

  validates :file, :relic, :user, :presence => true
  validates :name, :description, :presence => true, :unless => :new_record?

  has_paper_trail :skip => [:created_at, :updated_at]

  def remove_file!
    Rails.logger.info("skip removing physical file of document ##{self.id} ")
  end

  def mime_class
    (mime || "").gsub(/application\//, '').gsub(/\W+/, '-')
  end

  before_save :update_file_attributes

  def ellipsisize
    name = file.to_s.split("/").last
    name[0..20] + "..." + name[-3..-1]
  end

  private

  def update_file_attributes
    if file.present? && file_changed?
      self.mime = file.file.content_type
      self.size = file.file.size
    end
  end
end
