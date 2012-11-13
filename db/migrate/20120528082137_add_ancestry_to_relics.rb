# -*- encoding : utf-8 -*-
class AddAncestryToRelics < ActiveRecord::Migration
  def change
    add_column :relics, :ancestry, :string
    add_column :relics, :source, :text
    add_index :relics, :ancestry
  end
end
