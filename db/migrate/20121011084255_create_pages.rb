# -*- encoding : utf-8 -*-
class CreatePages < ActiveRecord::Migration
  def up
    create_table :pages do |t|
      t.string :name
      t.string :title
      t.text :body

      t.timestamps
    end
    Page.create_translation_table! :title => :string, :body => :text
  end

  def self.down
    drop_table :pages
    Page.drop_translation_table!
  end
end
