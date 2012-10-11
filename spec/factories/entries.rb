# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :entry do
    relic
    user :factory => :registered_user
    sequence(:title) { |n| "Sample Title #{n}" }
    sequence(:body) { |n| "Very long body of entry number #{n}" }
  end
end
