class CreateSeenRelics < ActiveRecord::Migration
  def change
    create_table :seen_relics do |t|
      t.integer :user_id
      t.integer :relic_id

      t.timestamps
    end
    add_index :seen_relics, :user_id
    add_index :seen_relics, :relic_id
    add_index :seen_relics, [:user_id, :relic_id]
    add_index :search_terms, :keyword
  end
end
