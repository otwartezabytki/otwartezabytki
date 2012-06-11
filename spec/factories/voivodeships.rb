# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :voivodeship do

    name "voivodeship"

    factory :voivodeship_dolnoslaskie do
      name "dolnośląskie"
    end

    factory :voivodeship_mazowieckie do
      name "mazowieckie"
    end

    factory :voivodeship_podlaskie do
      name "podlaskie"
    end

  end
end
