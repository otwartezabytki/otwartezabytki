# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :relic do
    id 1
    place_id 1
    identification "MyText"
    group "MyString"
    number 1
    materail "MyString"
    dating_of_obj "MyString"
    street "MyString"
    register_number "MyString"
    national_number "MyString"
  end
end
