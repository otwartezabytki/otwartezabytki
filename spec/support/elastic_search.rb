# -*- encoding : utf-8 -*-
def refresh_relics_index
  Relic.tire.index.delete
  Relic.tire.index.create(:mappings => Relic.tire.mapping_to_hash, :settings => Relic.tire.settings)
  if Relic.count == 0
    Relic.tire.index.import [create(:relic)]
  else
    Relic.tire.index.import Relic.all
  end

  Relic.tire.index.refresh
end
