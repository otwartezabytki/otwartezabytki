class SetDefaultRoleForUsers < ActiveRecord::Migration
  def up
    change_column_default(:users, :role, 'user')
    execute "update users set role = 'user' where role is null"
  end

  def down
    change_column_default(:users, :role, nil)
  end
end
