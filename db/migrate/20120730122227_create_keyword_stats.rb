class CreateKeywordStats < ActiveRecord::Migration
  def change
    create_table :keyword_stats do |t|
      t.string :identification
      t.integer :count

      t.timestamps
    end
  end
end
