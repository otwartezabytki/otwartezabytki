class AddCommonNameToRelics < ActiveRecord::Migration
  def change
    add_column :relics, :common_name, :string, :default => ""
  end
end
