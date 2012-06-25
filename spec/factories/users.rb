# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    role "user"

    trait :with_credentials do
      sequence(:email) {|n| "user#{n}@example.com" }
      sequence(:username) { |n| "user#{n}" }
    end

    trait :admin do
      sequence(:email) {|n| "user#{n}@example.com" }
      role "admin"
      password "password"
      password_confirmation { |u| u.password }
    end
  end
end
