# -*- encoding : utf-8 -*-
class AddRoleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :role, :string
  end
end
