# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :entry do |f|
    f.relic
    f.user :factory => :registered_user
    f.sequence(:title) { |n| "Sample Title #{n}" }
    f.sequence(:body) { |n| "Very long body of entry number #{n}" }
  end
end
