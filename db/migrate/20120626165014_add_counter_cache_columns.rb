# -*- encoding : utf-8 -*-
class AddCounterCacheColumns < ActiveRecord::Migration
  def change
    add_column :suggestions, :skipped, :boolean, :default => false
    add_column :relics, :skip_count, :integer, :default => 0
    add_column :relics, :edit_count, :integer, :default => 0
  end
end
