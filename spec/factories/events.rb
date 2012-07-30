# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event do
    relic_id 1
    user_id 1
    name "MyString"
    date "MyString"
    date_start "2012-07-30"
    date_end "2012-07-30"
  end
end
