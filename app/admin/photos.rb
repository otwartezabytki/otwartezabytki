# -*- encoding : utf-8 -*-

ActiveAdmin.register Photo do
  menu :label => "Zdjęcia", :parent => "Zasoby"

  index do
    column :id
    column :relic do |e|
      link_to e.relic.identification, admin_relic_path(e.relic_id)
    end
    column :author
    column :date_taken
    column :alternate_text
    column :photo do |e|
      image_tag e.file.midi.url
    end
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :relic_id
      f.input :author
      f.input :date_taken
      f.input :alternate_text
      f.input :description
      f.input :file
      f.buttons
    end
  end

  show do |e|
    attributes_table do
      row :id
      row :relic
      row :user
      row :author
      row :image do
        image_tag(e.file.full.url)
      end

      row :date_taken
      row :alternate_text
      row :description
      row :updated_at
      row :created_at
    end

    active_admin_comments
  end

  filter :id
  filter :relic_id, :as => :numeric
  filter :author
  filter :date_taken
  filter :alternate_text
end
