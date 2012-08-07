class AddDescriptionToRelics < ActiveRecord::Migration
  def change
    add_column :relics, :description, :text, :default => ''
  end
end
