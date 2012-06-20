class ModifyRelicStructure < ActiveRecord::Migration
  def change
    add_column :relics, :register_date, :date
    add_column :relics, :date_norm, :string
    add_column :relics, :date_start, :string
    add_column :relics, :date_end, :string
    add_column :relics, :kind, :string
    add_column :relics, :source_type, :string
    rename_column :relics, :national_number, :nid_id
  end
end