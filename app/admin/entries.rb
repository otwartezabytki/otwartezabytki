# -*- encoding : utf-8 -*-

ActiveAdmin.register Entry do
  menu :label => "Wpisy", :parent => "Zasoby"

  index do
    column :id
    column :relic do |e|
      link_to e.relic.identification, admin_relic_path(e.relic_id)
    end
    column :title
    column :body do |e|
      sanitize e.body
    end
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :relic_id
      f.input :title
      f.input :body, :wrapper_html => { :style => "width: 500px; position: relative;" }, :label => false
      f.buttons
    end
  end

  filter :id
  filter :relic_id, :as => :numeric
  filter :title
  filter :body
end
