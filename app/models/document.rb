class Document < ActiveRecord::Base
  belongs_to :relic
  belongs_to :user

  attr_accessible :mimetype, :name, :size, :file

  mount_uploader :file, DocumentUploader

  def remove_file!
    Rails.logger.info("skip removing physical file of document ##{self.id} ")
  end
end
