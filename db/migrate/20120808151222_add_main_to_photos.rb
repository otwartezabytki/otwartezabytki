# -*- encoding : utf-8 -*-
class AddMainToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :main, :boolean
  end
end
