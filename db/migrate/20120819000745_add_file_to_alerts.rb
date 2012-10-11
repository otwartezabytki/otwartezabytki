# -*- encoding : utf-8 -*-
class AddFileToAlerts < ActiveRecord::Migration
  def change
    add_column :alerts, :file, :string
  end
end
