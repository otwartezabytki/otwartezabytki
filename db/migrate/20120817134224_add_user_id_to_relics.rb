class AddUserIdToRelics < ActiveRecord::Migration
  def change
    add_column :relics, :user_id, :integer
  end
end
