# Read about factories at https://github.com/thoughtbot/factory_girl

include Rake::DSL

FactoryGirl.define do
  factory :photo do
    relic
    user :factory => :registered_user
    sequence(:name) { |n| "Sample Photo #{n}" }
    sequence(:author) { |n| "John Smith #{n}" }
    file { Rack::Test::UploadedFile.new(Rails.root + "spec/fixtures/files/photo.jpg", "image/jpeg") }
  end
end
