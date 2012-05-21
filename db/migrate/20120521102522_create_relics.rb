class CreateRelics < ActiveRecord::Migration
  def change
    create_table :relics do |t|
      t.integer :id
      t.integer :place_id
      t.text :identification
      t.string :group
      t.integer :number
      t.string :materail
      t.string :dating_of_obj
      t.string :street
      t.string :register_number
      t.string :national_number
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
