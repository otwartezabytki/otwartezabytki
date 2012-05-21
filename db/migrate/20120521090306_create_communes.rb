class CreateCommunes < ActiveRecord::Migration
  def change
    create_table :communes do |t|
      t.integer :id
      t.integer :district_id
      t.string :name

      t.timestamps
    end
  end
end
