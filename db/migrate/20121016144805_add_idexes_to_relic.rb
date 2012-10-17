class AddIdexesToRelic < ActiveRecord::Migration
  def change
    add_index :relics, :place_id
    add_index :relics, :commune_id
    add_index :relics, :district_id
    add_index :relics, :voivodeship_id
    add_index :relics, :type
    add_index :relics, :state
    add_index :relics, :existence
    add_index :relics, [:voivodeship_id, :state]
  end
end
