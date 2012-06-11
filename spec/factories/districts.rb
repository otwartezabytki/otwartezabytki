# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :district do

    voivodeship
    name "district"

    factory :district_jeleniogorski do
      voivodeship :factory => :voivodeship_dolnoslaskie
      name "jeleniogórski"
    end

    factory :district_warszawski do
      voivodeship :factory => :voivodeship_mazowieckie
      name "warszawski"
    end

    factory :district_suwalski do
      voivodeship :factory => :voivodeship_podlaskie
      name "podlaskie"
    end

  end
end
