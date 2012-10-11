# -*- encoding : utf-8 -*-
class AddCachingFieldsToRelic < ActiveRecord::Migration
  def change
    add_column :relics, :commune_id, :integer
    add_column :relics, :district_id, :integer
    add_column :relics, :voivodeship_id, :integer
  end
end
