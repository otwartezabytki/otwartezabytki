# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :page do |f|
    f.title "MyString"
    f.body "MyText"
  end
end
