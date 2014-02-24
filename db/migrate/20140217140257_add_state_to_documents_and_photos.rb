class AddStateToDocumentsAndPhotos < ActiveRecord::Migration
  def up
    add_column :documents, :state, :string, :default => 'initialized'
    add_column :photos,    :state, :string, :default => 'initialized'

    # set proper state for photos and documents
    Document.update_all({state: 'uploaded'}, 'file IS NOT NULL')
    Document.update_all({state: 'saved'}, 'name IS NOT NULL AND description IS NOT NULL')

    Photo.update_all({state: 'uploaded'}, 'file IS NOT NULL')
    Photo.update_all({state: 'saved'}, 'author IS NOT NULL AND date_taken IS NOT NULL')
  end

  def down
    remove_column :documents, :state
    remove_column :photos,    :state
  end
end
