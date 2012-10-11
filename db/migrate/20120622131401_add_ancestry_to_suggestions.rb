# -*- encoding : utf-8 -*-
class AddAncestryToSuggestions < ActiveRecord::Migration
  def change
    add_column :suggestions, :ancestry, :integer
    add_index :suggestions, :ancestry
  end
end
