class AddAutoCategoriesToRelic < ActiveRecord::Migration
  def change
    add_column :relics, :auto_categories, :string
  end
end
