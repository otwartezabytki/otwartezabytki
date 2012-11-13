# -*- encoding : utf-8 -*-
class CreateSuggestedTypes < ActiveRecord::Migration
  def change
    create_table :suggested_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
