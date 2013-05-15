# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

include Rake::DSL

FactoryGirl.define do
  factory :photo do |f|
    f.relic
    f.user :factory => :registered_user
    f.sequence(:date_taken) { |n| "2012-06-1#{n}" }
    f.sequence(:author) { |n| "John Smith #{n}" }
    f.file { File.open(Rails.root.join("spec/fixtures/files/photo.jpg")) }

    factory :uploaded_photo do |f|
      f.file { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/photo.jpg"), 'image/png') }
    end
  end
end
