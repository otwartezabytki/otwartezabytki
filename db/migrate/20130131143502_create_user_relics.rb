class CreateUserRelics < ActiveRecord::Migration
  def change
    create_table :user_relics do |t|
      t.integer :user_id
      t.integer :relic_id

      t.timestamps
    end
  end
end
