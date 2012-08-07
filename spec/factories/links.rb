# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :link do
    relic
    user :factory => :registered_user
    name "MyString"
    url "MyString"
  end
end
