# -*- encoding : utf-8 -*-
class RenameKeywordStats < ActiveRecord::Migration
  def up
    rename_table :keyword_stats, :autocomplitions
    remove_column :autocomplitions, :count
    rename_column :autocomplitions, :identification, :name
    add_column :autocomplitions, :indexed_at, :datetime
  end

  def down
    remove_column :autocomplitions, :indexed_at
    rename_column :autocomplitions, :name, :identification
    add_column :autocomplitions, :count, :integer
    rename_table :autocomplitions, :keyword_stats
  end
end
