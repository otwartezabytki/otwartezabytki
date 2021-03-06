# -*- encoding : utf-8 -*-

class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::Meta

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "system/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :icon do
    process :resize_to_fill => [24, 24]
  end

  version :mini do
    process :resize_to_fill => [48, 48]
  end

  version :midi do
    process :resize_to_fill => [64, 64]
  end

  version :maxi do
    process :resize_to_fill => [320, 320]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg png)
  end

  # fallback
  def default_url
    "/assets/fallback/" + ["avatar", version_name, "default.png"].compact.join('_')
  end
end
