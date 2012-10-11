# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :alert do
    relic_id 1
    user_id 1
    kind "MyString"
    description "MyString"
  end
end
