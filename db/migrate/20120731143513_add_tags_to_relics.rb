# -*- encoding : utf-8 -*-
class AddTagsToRelics < ActiveRecord::Migration
  def change
    add_column :relics, :tags, :string
  end
end
