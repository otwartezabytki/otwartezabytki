# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :category do |f|
    f.key_name "MyString"
    f.position 1
    f.group_key "MyString"
  end
end
