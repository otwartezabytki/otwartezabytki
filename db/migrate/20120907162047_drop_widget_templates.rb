class DropWidgetTemplates < ActiveRecord::Migration
  def up
    drop_table :widget_templates
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
