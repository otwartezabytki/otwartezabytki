class AddLatLngToTerytModels < ActiveRecord::Migration
  def change
    add_column :communes, :latitude, :float
    add_column :communes, :longitude, :float
    add_column :communes, :viewport, :string

    add_column :districts, :latitude, :float
    add_column :districts, :longitude, :float
    add_column :districts, :viewport, :string

    add_column :voivodeships, :latitude, :float
    add_column :voivodeships, :longitude, :float
    add_column :voivodeships, :viewport, :string

    add_column :places, :viewport, :string
  end
end
