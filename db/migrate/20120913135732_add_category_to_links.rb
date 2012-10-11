# -*- encoding : utf-8 -*-
class AddCategoryToLinks < ActiveRecord::Migration
  def change
    add_column :links, :category, :string
  end
end
