# -*- encoding : utf-8 -*-
class AddApprovedFieldToRelic < ActiveRecord::Migration
  def change
    add_column :relics, :approved, :boolean, :default => false
  end
end
