class AddPositionToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :position, :integer
    Relic.all.each do |relic|
      relic.photos.order(:updated_at).each.with_index(1) do |photo, index|
        photo.update_column :position, index
      end
    end
  end
end
