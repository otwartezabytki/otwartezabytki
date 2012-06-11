# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :commune do

    district
    name "commune"

    factory :commune_bardo do
      name "Bardo"
      district :factory => :district_jeleniogorski
    end

    factory :commune_leszno do
      name "Leszno"
      district :factory => :district_warszawski
    end

    factory :commune_suwalki do
      name "Suwalki"
      district :factory => :district_suwalski
    end

  end
end
