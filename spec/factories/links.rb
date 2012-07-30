# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :link do
    relic_id 1
    user_id 1
    name "MyString"
    url "MyString"
  end
end
