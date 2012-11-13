# -*- encoding : utf-8 -*-
class AddTagsToModels < ActiveRecord::Migration
  def change
    add_column :relics, :tags, :string
    add_column :suggestions, :tags, :string
    add_column :suggestions, :tags_action, :string
  end
end
