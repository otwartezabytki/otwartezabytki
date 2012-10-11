# -*- encoding : utf-8 -*-
class AddSourceToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :source, :string
  end
end
