class AutocomplitionAddCount < ActiveRecord::Migration
  def up
    add_column :autocomplitions, :count, :integer, :default => 0
  end

  def down
    remove_column :autocomplitions, :count
  end
end
