# -*- encoding : utf-8 -*-
class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.integer :relic_id
      t.integer :user_id
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
