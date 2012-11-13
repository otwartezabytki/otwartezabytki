# -*- encoding : utf-8 -*-
class AddDescriptionToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :description, :string
  end
end
