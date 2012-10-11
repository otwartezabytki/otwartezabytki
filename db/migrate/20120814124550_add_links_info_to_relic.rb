# -*- encoding : utf-8 -*-
class AddLinksInfoToRelic < ActiveRecord::Migration
  def change
    add_column :relics, :links_info, :text
  end
end
