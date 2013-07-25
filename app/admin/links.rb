# -*- encoding : utf-8 -*-

ActiveAdmin.register Link do
  menu :label => "Linki", :parent => "Zasoby"

  index do
    column :id
    column :relic do |e|
      link_to e.relic.identification, admin_relic_path(e.relic_id)
    end
    column :name
    column :url
    column :position
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :relic_id
      f.input :name
      f.input :url
      f.input :position
      f.buttons
    end
  end

  filter :id
  filter :relic_id, :as => :numeric
  filter :url
  filter :name
end
