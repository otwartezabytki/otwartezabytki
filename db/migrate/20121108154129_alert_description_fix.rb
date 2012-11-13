class AlertDescriptionFix < ActiveRecord::Migration
  def up
    change_column :alerts, :description, :text
  end

  def down
    change_column :alerts, :description, :string
  end
end
