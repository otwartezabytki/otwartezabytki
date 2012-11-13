class AddAncestryToCategories < ActiveRecord::Migration
  def up
    change_table :categories do |t|
      t.string :ancestry
      t.index :ancestry
      t.remove :group_key
    end
  end

  def down
    change_table :categories do |t|
      t.remove :ancestry
      t.remove_index :ancestry
      t.string :group_key
    end
  end
end
