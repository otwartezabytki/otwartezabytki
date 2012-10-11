# -*- encoding : utf-8 -*-
class AddVirtaulIdFields < ActiveRecord::Migration
  def change
    add_column :places, :virtual_commune_id, :string
  end
end
