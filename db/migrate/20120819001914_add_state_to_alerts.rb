# -*- encoding : utf-8 -*-
class AddStateToAlerts < ActiveRecord::Migration
  def change
    add_column :alerts, :state, :string
  end
end
