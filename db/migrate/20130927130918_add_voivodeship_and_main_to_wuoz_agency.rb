class AddVoivodeshipAndMainToWuozAgency < ActiveRecord::Migration
  def change
    add_column :wuoz_agencies, :main, :boolean, :default => false
    add_column :wuoz_agencies, :voivodeship_id, :integer
  end
end
