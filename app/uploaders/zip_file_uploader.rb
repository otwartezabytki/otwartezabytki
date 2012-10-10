# encoding: utf-8

class ZipFileUploader < CarrierWave::Uploader::Base

  storage :file

  def store_dir
    "system/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads/zipfiles"
  end

  def extension_white_list
    %w(zip)
  end
end
