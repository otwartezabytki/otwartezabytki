# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :place do |f|

    f.commune
    f.name "place"

    factory :place_bardo do |f|
      f.name "Bardo"
      f.commune :factory => :commune_bardo
    end

    factory :place_leszno do |f|
      f.name "Leszno"
      f.commune :factory => :commune_leszno
    end

    factory :place_magdalenowo do |f|
      f.name "Magdalenowo"
      f.commune :factory => :commune_suwalki
    end

  end
end
