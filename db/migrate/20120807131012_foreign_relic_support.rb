# -*- encoding : utf-8 -*-
class ForeignRelicSupport < ActiveRecord::Migration
  def up
    change_column :relics, :register_number, :text
    add_column :relics, :type, :string, :default => 'Relic'
    add_column :relics, :country_code, :string, :default => 'PL'
    add_column :relics, :fprovince, :string
    add_column :relics, :fplace, :string
  end

  def down
    change_column :relics, :register_number, :string
    remove_column :relics, :type, :country_code, :fprovince, :fplace
  end
end
