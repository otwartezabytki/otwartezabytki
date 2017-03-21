class AddPositionInGroupOfRelics < ActiveRecord::Migration
  def up
    add_column :photos, :position_in_group_of_relics, :integer
    Relic.find_each do |relic|
      relic.photos.order(:updated_at).each.with_index(1) do |photo, index|
        photo.update_column :position_in_group_of_relics, index
      end
    end
  end

  def down
    remove_column :photos, :position_in_group_of_relics
  end
end
