class CreateSearchTerms < ActiveRecord::Migration
  def change
    create_table :search_terms do |t|
      t.string :keyword
      t.integer :count, :default => 1

      t.timestamps
    end
  end
end
