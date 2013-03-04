class AddPgTrgmExtenstion < ActiveRecord::Migration
  def up
    execute "create extension pg_trgm;"
    execute "CREATE INDEX relics_ancestry_trgm_idx ON relics USING gin (ancestry gin_trgm_ops);"
    execute "CREATE INDEX categories_ancestry_trgm_idx ON categories USING gin (ancestry gin_trgm_ops);"
    execute "CREATE INDEX original_relics_ancestry_trgm_idx ON original_relics USING gin (ancestry gin_trgm_ops);"
  end

  def down
    drop_index "relics_ancestry_trgm_idx"
    drop_index "categories_ancestry_trgm_idx"
    drop_index "original_relics_ancestry_trgm_idx"
  end
end
