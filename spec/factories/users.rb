# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "user#{n}@example.com" }

    trait :admin do
      role "admin"
      password "password"
      password_confirmation { |u| u.password }
    end
  end
end
