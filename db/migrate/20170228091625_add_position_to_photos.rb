class AddPositionToPhotos < ActiveRecord::Migration
  def up
    add_column :photos, :position, :integer
    Relic.find_each do |relic|
      relic.photos.order(:updated_at).each.with_index(1) do |photo, index|
        photo.update_column :position, index
      end
    end
  end

  def down
    remove_column :photos, :position
  end
end
