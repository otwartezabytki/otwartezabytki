# -*- encoding : utf-8 -*-
class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.integer :relic_id
      t.integer :user_id
      t.string :name
      t.string :url

      t.timestamps
    end
  end
end
