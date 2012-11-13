# -*- encoding : utf-8 -*-
class AddApiKeysToUser < ActiveRecord::Migration
  def change
    add_column :users, :api_key, :string
    add_column :users, :api_secret, :string
  end
end
