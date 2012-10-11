# -*- encoding : utf-8 -*-
class AddCustomToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :custom, :boolean, :default => false
  end
end
