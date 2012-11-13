# -*- encoding : utf-8 -*-
class AddDateTakenToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :date_taken, :string
  end
end
