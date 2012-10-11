# -*- encoding : utf-8 -*-
class AddKindToLinks < ActiveRecord::Migration
  def change
    add_column :links, :kind, :string
  end
end
