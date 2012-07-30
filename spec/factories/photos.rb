# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :photo do
    relic
    user
    name "Sample Photo"
    author "Adam Stankiewicz"
  end
end
