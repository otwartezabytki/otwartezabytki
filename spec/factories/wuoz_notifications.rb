# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :wuoz_notification do |f|
    f.wuoz_agency_id 1
    f.subject "MyText"
    f.body "MyText"
    f.alert_ids "MyText"
    f.zip_file "MyString"
  end
end
