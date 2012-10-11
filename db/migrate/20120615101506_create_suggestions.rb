# -*- encoding : utf-8 -*-
class CreateSuggestions < ActiveRecord::Migration
  def change
    create_table :suggestions do |t|

      t.integer  :relic_id
      t.integer  :user_id

      t.integer  :place_id
      t.string   :place_id_action, :default => "skip"

      t.text     :identification
      t.string   :identification_action, :default => "skip"

      t.string   :street
      t.string   :street_action, :default => "skip"

      t.string   :dating_of_obj
      t.string   :dating_of_obj_action, :default => "skip"

      t.float    :latitude
      t.float    :longitude
      t.string   :coordinates_action, :default => "skip"

      t.timestamps
    end

    add_index :suggestions, :place_id_action
    add_index :suggestions, :identification_action
    add_index :suggestions, :dating_of_obj_action
    add_index :suggestions, :coordinates_action
  end
end
