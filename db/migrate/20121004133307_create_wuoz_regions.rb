class CreateWuozRegions < ActiveRecord::Migration
  def change
    create_table :wuoz_regions do |t|
      t.integer :wuoz_agency_id
      t.integer :district_id

      t.timestamps
    end
  end
end
