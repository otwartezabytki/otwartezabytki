class AddStateAndExistenceToRelics < ActiveRecord::Migration
  def change
    add_column :relics, :state, :string
    add_column :relics, :existence, :string
  end
end
