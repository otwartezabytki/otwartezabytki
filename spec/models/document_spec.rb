require 'spec_helper'

describe Document do
  it "should belong to relic and user" do
    build(:document).should respond_to(:user)
    build(:document).should respond_to(:relic)
  end

  it "should have working uploader on file attribute" do
    document = create(:document)
    document.file = File.open(Rails.root + 'public/favicon.gif')
    document.save!

    document.file.should_not be_nil
    document.file.url.should_not be_nil
    document.file.current_path.should include(Rails.root)
    document.file.identifier.should include('favicon')
  end

  it "should upload each document under /public/system/uploads/document path" do
    document = create(:document)
    document.file = File.open(Rails.root + 'public/favicon.gif')
    document.save!

    document.file.current_path.should include('/public/system/uploads/document')
  end

  it "should upload each document under different path and don't delete old file" do
    document = create(:document)
    document.file = File.open(Rails.root + 'public/favicon.gif')
    document.save!

    first_path = document.file.current_path

    document.file = File.open(Rails.root + 'public/robots.txt')
    document.save!

    second_path = document.file.current_path

    first_path.should_not equal(second_path)
    File.exist?(second_path).should be_true
    File.exist?(first_path).should be_true
  end
end
