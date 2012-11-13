# -*- encoding : utf-8 -*-
class RemoveKindFromAlerts < ActiveRecord::Migration
  def up
    remove_column :alerts, :kind
  end

  def down
    add_column :alerts, :kind, :string
  end
end
