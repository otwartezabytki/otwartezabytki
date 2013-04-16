# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :voivodeship do |f|
    f.name "voivodeship"

    factory :voivodeship_dolnoslaskie do |f|
      f.name "dolnośląskie"
    end

    factory :voivodeship_mazowieckie do |f|
      f.name "mazowieckie"
    end

    factory :voivodeship_podlaskie do |f|
      f.name "podlaskie"
    end

  end
end
