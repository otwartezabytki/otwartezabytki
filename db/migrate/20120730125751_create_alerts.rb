# -*- encoding : utf-8 -*-
class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.integer :relic_id
      t.integer :user_id
      t.string :kind
      t.string :description

      t.timestamps
    end
  end
end
