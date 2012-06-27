# -*- encoding : utf-8 -*-
module RelicsHelper
  def wizard_full_place(relic)
    ["woj. #{relic.voivodeship.name}", "pow. #{relic.district.name}", "gm. #{relic.commune.name}"].join(', ')
  end
end
