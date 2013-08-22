# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :alert do |f|
    f.relic_id 1
    f.user_id 1
    f.kind "MyString"
    f.description "MyString"
    f.file { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/photo.jpg")) }
  end
end
