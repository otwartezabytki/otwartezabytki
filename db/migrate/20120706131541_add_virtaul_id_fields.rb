class AddVirtaulIdFields < ActiveRecord::Migration
  def change
    add_column :places, :virtual_commune_id, :string
  end
end
