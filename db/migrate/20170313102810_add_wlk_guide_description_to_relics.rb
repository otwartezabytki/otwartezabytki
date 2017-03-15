class AddWlkGuideDescriptionToRelics < ActiveRecord::Migration
  def change
    add_column :relics, :wlk_guide_description, :text
  end
end
