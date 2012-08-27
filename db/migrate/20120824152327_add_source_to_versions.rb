class AddSourceToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :source, :string
  end
end
