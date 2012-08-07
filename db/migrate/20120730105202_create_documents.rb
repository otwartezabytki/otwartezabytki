class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.integer :relic_id
      t.integer :user_id
      t.string :name
      t.integer :size
      t.string :mime
      t.string :file

      t.timestamps
    end
  end
end
