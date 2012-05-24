# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :district do
    id 1
    voivodship_id 1
    name "MyString"
  end
end
