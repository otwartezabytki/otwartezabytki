class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.integer :relic_id
      t.integer :user_id
      t.string :name
      t.string :author
      t.string :file

      t.timestamps
    end
  end
end
