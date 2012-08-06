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
    categories ["Sample Category", "Another Interesting Category", "Some Third Category"]
    tags ["cmentarz", "boisko", "niedźwiedzie", "piękne"]
    description "<p>Some very long an interesting description. <strong>It can have some html tags</strong>.</p>"

    latitude 54.1312341234
    longitude 23.2412341122

    trait :in_bardo do
      place :factory => :place_bardo
    end

    trait :without_description do
      description nil
    end

    trait :without_tags do
      tags []
    end

    factory :relic_with_entries do
      after(:create) do |relic|
        create_list(:entry, 4, :relic => relic)
      end
    end

    factory :relic_with_photos do
      after(:create) do |relic|
        4.times do
          relic.photos << create(:photo, :relic => relic)
        end
      end
    end

    factory :relic_with_links do
      after(:create) do |relic|
        create_list(:link, 4, :relic => relic)
      end
    end

    factory :relic_with_events do
      after(:create) do |relic|
        create_list(:event, 4, :relic => relic)
      end
    end
  end
end
