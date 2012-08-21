class AddBuildStateToRelic < ActiveRecord::Migration
  def change
    add_column :relics, :build_state, :string
  end
end
