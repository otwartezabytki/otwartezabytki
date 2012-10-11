# -*- encoding : utf-8 -*-
class AddTerytFields < ActiveRecord::Migration
  def change
    add_column :voivodeships, :nr, :string
    add_column :districts, :nr, :string
    add_column :communes, :nr, :string
    add_column :communes, :kind, :integer
    add_column :places, :sym, :string
  end
end
