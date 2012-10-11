# -*- encoding : utf-8 -*-
class AddIpAddressToSuggestions < ActiveRecord::Migration
  def change
    add_column :suggestions, :ip_address, :string
  end
end
