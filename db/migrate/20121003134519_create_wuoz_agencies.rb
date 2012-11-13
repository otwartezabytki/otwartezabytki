# -*- encoding : utf-8 -*-
class CreateWuozAgencies < ActiveRecord::Migration
  def change
    create_table :wuoz_agencies do |t|
      t.string :city
      t.string :director
      t.string :email
      t.string :address
      t.string :districts
      t.string :wuoz_key

      t.timestamps
    end
  end
end
