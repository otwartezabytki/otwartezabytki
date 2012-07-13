class UserAddSeenRelicOrder < ActiveRecord::Migration
  def change
    add_column :users, :seen_relic_order, :string, :default => 'asc'
  end
end
