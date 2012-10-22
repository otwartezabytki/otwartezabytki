class RelicCleanUpFileds < ActiveRecord::Migration
  def up
    change_table :relics do |t|
      t.remove :group
      t.remove :number
      t.remove :materail
      t.remove :internal_id
      t.remove :source
      t.remove :register_date
      t.remove :date_norm
      t.remove :skip_count
      t.remove :edit_count
    end
  end

  def down
    change_table :relics do |t|
      t.string :group
      t.integer :number
      t.string :material
      t.string :internal_id
      t.text :source
      t.date :register_date
      t.string :date_norm
      t.integer :skip_count, :default => 0
      t.integer :edit_count, :default => 0
    end
  end
end
