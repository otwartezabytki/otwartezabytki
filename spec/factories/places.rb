# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :place do

    commune
    name "place"

    factory :place_bardo do
      name "Bardo"
      commune :factory => :commune_bardo
    end

    factory :place_leszno do
      name "Leszno"
      commune :factory => :commune_leszno
    end

    factory :place_magdalenowo do
      name "Magdalenowo"
      commune :factory => :commune_suwalki
    end

  end
end
