# -*- encoding : utf-8 -*-
class AddDefaultValueToTagsAction < ActiveRecord::Migration
  def change
    change_column_default :suggestions, :tags_action, 'skip'
  end
end
