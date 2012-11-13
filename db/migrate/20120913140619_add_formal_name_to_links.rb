# -*- encoding : utf-8 -*-
class AddFormalNameToLinks < ActiveRecord::Migration
  def change
    add_column :links, :formal_name, :string
  end
end
