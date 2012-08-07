# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    role "user"

    trait :with_credentials do
      sequence(:email) { Forgery(:internet).email_address }
      sequence(:username) { Forgery(:internet).user_name }
      password "password"
      password_confirmation { |u| u.password }
    end

    trait :admin do
      sequence(:email) {|n| "user#{n}@example.com" }
      role "admin"
      password "password"
      password_confirmation { |u| u.password }
    end

    factory :registered_user do
      with_credentials
    end

    factory :admin_user do
      with_credentials
      admin
    end
  end
end
