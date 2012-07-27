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

  def has_photos_facets
    # total   = relics.facets['has_photos']['total']
    # t_count = relics.terms('has_photos').find {|t| t['term'] == 'T' }.try(:[], 'count') || 0
    # f_count = relics.terms('has_photos').find {|t| t['term'] == 'F' }.try(:[], 'count') || 0
    [
      ["wszystkie", nil],
      ["ze zdjęciem" , true],
      ["brak zdjęcia", false]
    ]
  end

  def has_description_facets
    # total   = relics.facets['has_description']['total']
    # t_count = relics.terms('has_description').find {|t| t['term'] == 'T'}.try(:[], 'count') || 0
    # f_count = relics.terms('has_description').find {|t| t['term'] == 'F' }.try(:[], 'count') || 0
    [
      ["wszystkie", nil],
      ["z opisem", true],
      ["brak opisu", false]
    ]
  end

end
