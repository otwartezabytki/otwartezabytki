class ChangeUserDefaultLocaleValue < ActiveRecord::Migration
  def up
    change_column :users, :default_locale, :string, :default => nil
    execute <<-SQL
      UPDATE users SET default_locale = NULL where 1=1
    SQL
  end

  def down
    change_column :users, :default_locale, :string, :default => 'pl'
  end
end
