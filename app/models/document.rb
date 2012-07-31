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

  attr_accessible :mimetype, :name, :size, :file

  mount_uploader :file, DocumentUploader

  def remove_file!
    Rails.logger.info("skip removing physical file of document ##{self.id} ")
  end
end
