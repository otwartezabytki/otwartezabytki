# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :wuoz_region do |f|
    f.wuoz_agency_id 1
    f.district_id 1
  end
end
