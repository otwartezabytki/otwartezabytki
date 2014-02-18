class AddStateToDocumentsAndPhotos < ActiveRecord::Migration
  def change
    add_column :documents, :state, :string, :default => 'initialized'
    add_column :photos,    :state, :string, :default => 'initialized'
  end
end
