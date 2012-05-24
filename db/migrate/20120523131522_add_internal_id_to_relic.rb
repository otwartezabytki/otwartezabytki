# -*- encoding : utf-8 -*-
class AddInternalIdToRelic < ActiveRecord::Migration
  def change
    add_column :relics, :internal_id, :string
  end
end
