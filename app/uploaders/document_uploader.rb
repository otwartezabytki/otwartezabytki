# encoding: utf-8

class DocumentUploader < CarrierWave::Uploader::Base

  storage :file

  def store_dir
    "system/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_black_list
    %w(exe jar)
  end

end
