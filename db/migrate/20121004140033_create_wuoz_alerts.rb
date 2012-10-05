class CreateWuozAlerts < ActiveRecord::Migration
  def change
    create_table :wuoz_alerts do |t|
      t.integer :wuoz_agency_id
      t.integer :alert_id
      t.datetime :sent_at

      t.timestamps
    end
  end
end
