class AddGeocodedToRelics < ActiveRecord::Migration
  def change
    add_column :relics, :geocoded, :boolean
  end
end
