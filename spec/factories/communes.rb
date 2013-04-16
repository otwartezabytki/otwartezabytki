# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :commune do |f|

    f.district
    f.name "commune"

    factory :commune_bardo do |f|
      f.name "Bardo"
      f.district :factory => :district_jeleniogorski
    end

    factory :commune_leszno do |f|
      f.name "Leszno"
      f.district :factory => :district_warszawski
    end

    factory :commune_suwalki do |f|
      f.name "Suwalki"
      f.district :factory => :district_suwalski
    end

  end
end
