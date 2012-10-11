# -*- encoding : utf-8 -*-
class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :relic_id
      t.integer :user_id
      t.string :name
      t.string :date
      t.date :date_start
      t.date :date_end

      t.timestamps
    end
  end
end
