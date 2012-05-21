# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :commune do
    id 1
    district_id 1
    name "MyString"
  end
end
