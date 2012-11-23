class SetDefaultRelicKind < ActiveRecord::Migration
  def up
    change_column_default(:relics, :kind, "SA")
    execute "UPDATE relics SET kind = 'SA' WHERE kind is null"
  end

  def down
    change_column_default(:relics, :kind, nil)
  end
end
