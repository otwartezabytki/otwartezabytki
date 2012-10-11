# -*- encoding : utf-8 -*-
class AddDescriptionToRelics < ActiveRecord::Migration
  def change
    add_column :relics, :description, :text, :default => ''
  end
end
