# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :link do |f|
    f.relic
    f.user :factory => :registered_user
    f.name "MyString"
    f.url "MyString"
  end
end
