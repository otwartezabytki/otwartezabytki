ActiveAdmin.register WidgetTemplate do
  controller.authorize_resource

  index do
    column :id
    column :type
    column :name
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
      f.input :thumb, :as => :file
    end

    f.buttons
  end

end
