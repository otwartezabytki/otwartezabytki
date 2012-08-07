# -*- encoding : utf-8 -*-
module RelicsHelper
  def thank_you_note
    [
      "Dzięki Tobie Cyfrowy Czyn Społeczny działa :)",
      "Zabytki są Ci wdzięczne :)",
      "Cieszymy się, że otwierasz z nami zabytki :)",
      "Zabytki lubią być otwarte. Dziękujemy! :)",
      "Jesteś naszym zabytkowym aniołem :)",
      "Od zabytków głowa nie boli :) Dziękujemy!",
      "Każdy sprawdzony zabytek to krok do sukcesu akcji. Dziękujemy :)",
      "Miło, że poświęcasz swój czas na otwieranie zabytków :)",
      "Zabytki leżą nam na sercu :) Doceniamy, że bierzesz udział w akcji.",
      "Kolejny sprawdzony zabytek :) Ale fajnie!",
      "Dziękujemy! Im nas więcej, tym lepiej :)"
    ].sample
  end

  def categoires_facets
    relics.terms('categories', true).map do |t|
      ["#{Category.all.key(t['term'])} (#{t['count']})", t['term']]
    end
  end

  def state_facets
    labels = Hash[Relic::States.zip(['sprawdzone', 'niesprawdzone', 'uzupełnione'])]
    relics.terms('state', true).map do |t|
      ["#{labels[t['term']]} (#{t['count']})", t['term']]
    end
  end

  def existance_facets
    labels = Hash[Relic::Existences.zip(['istniejące w rejestrze', 'archiwalne', 'społecznie dodane'])]
    relics.terms('existance', true).map do |t|
      ["#{labels[t['term']]} (#{t['count']})", t['term']]
    end
  end

  def has_photos_facets
    labels = {'F' => 'brak zdjęcia', 'T' => 'ze zdjęciem'}
    relics.terms('has_photos', true).map do |t|
      ["#{labels[t['term']]} (#{t['count']})", t['term']]
    end
  end

  def has_description_facets
    labels = {'F' => 'brak opisu', 'T' => 'z opisem'}
    relics.terms('has_description', true).map do |t|
      ["#{labels[t['term']]} (#{t['count']})", t['term']]
    end
  end

  def disabled search, name
    relics.terms(name).inject([]) { |r, t|
      r <<  t['term'] if  t['count'].zero?
      r
    } - search.send(name)
  end

  def order_collection
    [
      ['Trafnosc ASC', 'score.asc'],
      ['Trafnosc DESC', 'score.desc'],
      ['A-Z', 'alfabethic.asc'],
      ['Z-A', 'alfabethic.desc'],
    ]
  end

end
