class RemoveSourceTypeColumn < ActiveRecord::Migration
  def change
    remove_column :relics, :source_type
  end
end
