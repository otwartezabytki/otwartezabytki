# -*- encoding : utf-8 -*-
class FixVoivodeshipTypo < ActiveRecord::Migration
  def up
    rename_column :districts, :voivodship_id, :voivodeship_id
  end

  def down
    rename_column :districts, :voivodeship_id, :voivodship_id
  end
end
