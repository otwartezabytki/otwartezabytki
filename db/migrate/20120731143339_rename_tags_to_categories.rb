# -*- encoding : utf-8 -*-
class RenameTagsToCategories < ActiveRecord::Migration
  def up
    rename_column :relics, :tags, :categories
  end

  def down
    rename_column :relics, :categories, :tags
  end
end
