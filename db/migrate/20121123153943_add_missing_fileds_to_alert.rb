class AddMissingFiledsToAlert < ActiveRecord::Migration
  def change
    add_column :alerts, :author, :string
    add_column :alerts, :date_taken, :string
  end
end
