require 'spec_helper'

describe Photo do
  it "should belong to relic and user" do
    build(:photo).should respond_to(:user)
    build(:photo).should respond_to(:relic)
  end

  it "should have working uploader on file attribute" do
    photo = create(:photo)
    photo.file = File.open(Rails.root + 'public/favicon.gif')
    photo.save!

    photo.file.should_not be_nil
    photo.file.url.should_not be_nil
    photo.file.current_path.should include(Rails.root)
    photo.file.identifier.should include('favicon')
  end

  it "should upload each photo under /public/system/uploads/photo path" do
    photo = create(:photo)
    photo.file = File.open(Rails.root + 'public/favicon.gif')
    photo.save!

    photo.file.current_path.should include('/public/system/uploads/photo')
  end

  it "should upload each photo under different path and don't delete old file" do
    photo = create(:photo)
    photo.file = File.open(Rails.root + 'public/favicon.gif')
    photo.save!

    first_path = photo.file.current_path

    photo.file = File.open(Rails.root + 'public/robots.txt')
    photo.save!

    second_path = photo.file.current_path

    first_path.should_not equal(second_path)
    File.exist?(second_path).should be_true
    File.exist?(first_path).should be_true
  end
end
