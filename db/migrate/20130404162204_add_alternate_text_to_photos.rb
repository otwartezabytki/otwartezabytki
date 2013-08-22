class AddAlternateTextToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :alternate_text, :string
  end
end
