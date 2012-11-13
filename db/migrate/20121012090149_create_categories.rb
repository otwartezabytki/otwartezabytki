class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name_key
      t.integer :position
      t.string :group_key
      t.string :column

      t.timestamps
    end
  end
end
