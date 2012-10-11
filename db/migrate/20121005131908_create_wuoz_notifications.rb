# -*- encoding : utf-8 -*-
class CreateWuozNotifications < ActiveRecord::Migration
  def change
    create_table :wuoz_notifications do |t|
      t.integer :wuoz_agency_id
      t.text :subject
      t.text :body
      t.text :alert_ids
      t.string :zip_file

      t.timestamps
    end
  end
end
