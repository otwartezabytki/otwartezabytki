class AddDefaultLocaleFieldToUser < ActiveRecord::Migration
  def change
    add_column :users, :default_locale, :string, :default => 'pl'
  end
end
