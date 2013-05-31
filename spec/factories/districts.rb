# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :district do |f|

    f.voivodeship
    f.name "district"

    factory :district_jeleniogorski do |f|
      f.voivodeship :factory => :voivodeship_dolnoslaskie
      f.name "jeleniogórski"
    end

    factory :district_warszawski do |f|
      f.voivodeship :factory => :voivodeship_mazowieckie
      f.name "warszawski"
    end

    factory :district_suwalski do |f|
      f.voivodeship :factory => :voivodeship_podlaskie
      f.name "podlaskie"
    end

  end
end
