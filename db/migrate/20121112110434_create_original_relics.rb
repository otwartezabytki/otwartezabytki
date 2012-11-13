class CreateOriginalRelics < ActiveRecord::Migration
  def change
    create_table :original_relics do |t|
      t.integer :relic_id
      t.integer :place_id
      t.text :identification
      t.string :dating_of_obj
      t.string :street
      t.text :register_number
      t.string :nid_id
      t.float :latitude
      t.float :longitude
      t.string :ancestry
      t.integer :commune_id
      t.integer :district_id
      t.integer :voivodeship_id
      t.string :kind
      t.text :description, :default => ""

      t.timestamps
    end
  end
end
