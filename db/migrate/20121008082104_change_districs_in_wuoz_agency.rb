class ChangeDistricsInWuozAgency < ActiveRecord::Migration
  def change
    rename_column :wuoz_agencies, :districts, :district_names
  end
end
