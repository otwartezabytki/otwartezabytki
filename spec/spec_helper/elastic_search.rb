def refresh_relics_index
  Relic.tire.index.delete
  Relic.tire.index.create(:mappings => Relic.tire.mapping_to_hash, :settings => Relic.tire.settings)
  Relic.tire.index.import Relic.all if Relic.count > 0
  Relic.tire.index.refresh
end