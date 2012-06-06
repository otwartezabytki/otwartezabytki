# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :relic do
    place
    identification "cmentarz przykościelny"
    group "w zespole klasztornym dominikanek"
    number 1
    materail "mur."
    dating_of_obj "1 poł. XVII"
    street "ul. Grabicka 3"
    register_number "267/60 z 7.03.1960; 26/76/A z 16.02.1978"
  end
end
