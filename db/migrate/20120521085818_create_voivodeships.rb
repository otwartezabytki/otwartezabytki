# -*- encoding : utf-8 -*-
class CreateVoivodeships < ActiveRecord::Migration
  def change
    create_table :voivodeships do |t|
      t.integer :id
      t.string :name

      t.timestamps
    end
  end
end
