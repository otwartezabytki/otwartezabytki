# -*- encoding : utf-8 -*-
class AddCommentToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :comment, :string
  end
end
