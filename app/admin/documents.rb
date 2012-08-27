# encoding: utf-8

ActiveAdmin.register Document do
  menu :label => "Dokumenty", :parent => "Zasoby"

  controller.authorize_resource

  index do
    column :id
    column :relic do |e|
      link_to e.relic.identification, admin_relic_path(e.relic_id)
    end
    column :name
    column :description
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :relic_id
      f.input :name
      f.input :description
      f.input :file
      f.buttons
    end

  end

  filter :id
  filter :relic_id, :as => :numeric
  filter :name
  filter :description
end
