# -*- encoding : utf-8 -*-
module RelicsHelper
  def wizard_full_place(relic)
    ["woj. #{relic.voivodeship.name}", "pow. #{relic.district.name}", "gm. #{relic.commune.name}"].join(', ')
  end

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
end
