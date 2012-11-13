# -*- encoding : utf-8 -*-
class ChangeTypeOfDateStartEndColumns < ActiveRecord::Migration
  def up
    remove_column :relics, :date_start
    remove_column :relics, :date_end
    remove_column :events, :date_start
    remove_column :events, :date_end

    add_column :relics, :date_start, :integer
    add_column :relics, :date_end, :integer
    add_column :events, :date_start, :integer
    add_column :events, :date_end, :integer
  end

  def down
    remove_column :relics, :date_start
    remove_column :relics, :date_end
    remove_column :events, :date_start
    remove_column :events, :date_end

    add_column :relics, :date_start, :string
    add_column :relics, :date_end, :string
    add_column :events, :date_start, :string
    add_column :events, :date_end, :string
  end
end
