# == Schema Information
#
# Table name: documents
#
#  id         :integer          not null, primary key
#  relic_id   :integer
#  user_id    :integer
#  name       :string(255)
#  size       :integer
#  mime       :string(255)
#  file       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Document < ActiveRecord::Base
  belongs_to :relic
  belongs_to :user

  attr_accessible :mimetype, :name, :size, :file, :description, :mime

  mount_uploader :file, DocumentUploader

  validates :file, :relic, :user, :presence => true
  validates :name, :description, :presence => true, :unless => :new_record?

  def remove_file!
    Rails.logger.info("skip removing physical file of document ##{self.id} ")
  end

  def mime_class
    mime.gsub(/application\//, '').gsub(/\W+/, '-')
  end

  before_save :update_file_attributes

  private

  def update_file_attributes
    if file.present? && file_changed?
      self.mime = file.file.content_type
      self.size = file.file.size
    end
  end
end
