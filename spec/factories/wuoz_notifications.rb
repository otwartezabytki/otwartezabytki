# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :wuoz_notification do
    wuoz_agency_id 1
    subject "MyText"
    body "MyText"
    alert_ids "MyText"
    zip_file "MyString"
  end
end
