class AddWeightFieldToPages < ActiveRecord::Migration
  def change
    add_column :pages, :weight, :integer, :default => 0
  end
end
