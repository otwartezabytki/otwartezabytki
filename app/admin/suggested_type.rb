# -*- encoding : utf-8 -*-

ActiveAdmin.register SuggestedType do
  menu :label => "Sugestie fraz", :parent => "Wyszukiwarka"

  index do
    column :name
    default_actions
  end

end
