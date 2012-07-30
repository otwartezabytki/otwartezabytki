# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :document do
    relic
    user
    name "Sample Document"
    size 1024
    mime "application/doc"
  end
end
