# -*- encoding : utf-8 -*-
class CreateWidgets < ActiveRecord::Migration
  def change
    create_table :widgets do |t|
      t.integer :user_id
      t.integer :widget_template_id
      t.string :uid
      t.text :config

      t.timestamps
    end
  end
end
