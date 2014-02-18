# -*- encoding : utf-8 -*-
class CreatePages < ActiveRecord::Migration
  def up
    create_table :pages do |t|
      t.string :name
      t.string :title
      t.string :permalink
      t.text :body

      t.timestamps
    end
    add_index :pages, :permalink
    Page.create_translation_table! :title => :string, :body => :text, :permalink => :string
  end

  def self.down
    drop_table :pages
    Page.drop_translation_table!
  end
end
