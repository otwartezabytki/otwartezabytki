# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :document do |f|
    f.relic
    f.user :factory => :registered_user
    f.name "Sample Document"
    f.size 1024
    f.mime "application/doc"
    f.file { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/photo.jpg")) }
  end
end
