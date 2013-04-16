# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event do |f|
    f.relic_id 1
    f.user_id 1
    f.name "MyString"
    f.date "MyString"
    f.date_start "2012-07-30"
    f.date_end "2012-07-30"
  end
end
