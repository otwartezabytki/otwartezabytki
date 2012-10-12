# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :category do
    key_name "MyString"
    position 1
    group_key "MyString"
  end
end
