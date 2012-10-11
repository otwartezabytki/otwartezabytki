# -*- encoding : utf-8 -*-
class AddDocumentsInfoToRelics < ActiveRecord::Migration
  def change
    add_column :relics, :documents_info, :text
  end
end
