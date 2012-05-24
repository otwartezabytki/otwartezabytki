# -*- encoding : utf-8 -*-
class CreateDistricts < ActiveRecord::Migration
  def change
    create_table :districts do |t|
      t.integer :id
      t.integer :voivodship_id
      t.string :name

      t.timestamps
    end
  end
end
