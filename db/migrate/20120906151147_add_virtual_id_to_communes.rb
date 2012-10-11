# -*- encoding : utf-8 -*-
class AddVirtualIdToCommunes < ActiveRecord::Migration
  def change
    add_column :communes, :virtual_id, :string
  end
end
