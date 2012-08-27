class CreateWidgetTemplates < ActiveRecord::Migration
  def change
    create_table :widget_templates do |t|
      t.string :type
      t.string :name
      t.text :description
      t.string :thumb

      t.timestamps
    end
  end
end
