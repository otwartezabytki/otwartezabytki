class AddWidthAndHeightToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :file_full_width, :integer
    add_column :photos, :file_full_height, :integer
  end
end
