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

  def categoires_facets column = nil
    relics.terms('categories', true).map do |t|
      if column.blank? or Category.send("#{column}_column").keys.include? t['term']
        ["#{Category.all[t['term']]} <em>#{t['count']}</em>".html_safe, t['term']]
      end
    end.compact
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

  def link_to_section_tab(name)
    link_to_unless_current "<span>#{t "relic_tabs." + name.to_s + ".name"}</span>".html_safe, edit_section_relic_path(relic.id, name), :remote => true
  end

  def state_tag relic
    labels = Hash[Relic::States.zip(['Sprawdzony', 'Niesprawdzony', 'Uzupełniony'])]
    content_tag :div, :class => 'tag' do
      content_tag :span, labels[relic.state], :class => relic.state
    end
  end

end
