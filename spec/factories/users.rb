# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do |f|
    f.role "user"

    factory :registered_user do |f|
      f.sequence(:email) { Forgery(:internet).email_address }
      f.sequence(:username) { Forgery(:internet).user_name }
      f.password "password"
      f.password_confirmation { |u| u.password }

      factory :admin_user do |f|
        f.role "admin"
      end

      factory :api_user do |f|
        f.api_key "test_key"
        f.api_secret "sample api secret"
      end
    end
  end
end
