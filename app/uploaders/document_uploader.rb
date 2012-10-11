# -*- encoding : utf-8 -*-

class DocumentUploader < CarrierWave::Uploader::Base

  storage :file

  def store_dir
    "system/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads/documents"
  end

  def extension_white_list
    %w(pdf jpg jpeg png tiff)
  end

  def remove!

  end

end
