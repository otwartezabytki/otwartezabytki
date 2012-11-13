# -*- encoding : utf-8 -*-
class DropTags < ActiveRecord::Migration
  def up
    drop_table :tags
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
