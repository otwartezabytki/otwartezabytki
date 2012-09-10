class AddStateAndExistenceToRelics < ActiveRecord::Migration
  def change
    add_column :relics, :state, :string, :default => "unchecked"
    add_column :relics, :existence, :string, :default => "existed"
  end
end
