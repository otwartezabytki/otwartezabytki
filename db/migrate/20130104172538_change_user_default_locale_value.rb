class ChangeUserDefaultLocaleValue < ActiveRecord::Migration
  def up
    change_column :users, :default_locale, :string, :default => nil
    User.update_all :default_locale => nil
  end

  def down
    change_column :users, :default_locale, :string, :default => 'pl'
  end
end
