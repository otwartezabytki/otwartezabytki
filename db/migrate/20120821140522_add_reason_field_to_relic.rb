# -*- encoding : utf-8 -*-
class AddReasonFieldToRelic < ActiveRecord::Migration
  def change
    add_column :relics, :reason, :text
  end
end
