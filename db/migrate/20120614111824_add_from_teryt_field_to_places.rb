class AddFromTerytFieldToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :from_teryt, :boolean, :default => true
  end
end
