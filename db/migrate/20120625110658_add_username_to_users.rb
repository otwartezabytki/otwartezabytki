# -*- encoding : utf-8 -*-
class AddUsernameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :username, :string
  end
end
