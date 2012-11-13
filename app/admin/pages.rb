# -*- encoding : utf-8 -*-

ActiveAdmin.register Page do
  menu :label => "Strony statyczne"
  actions :index, :edit, :update, :new, :create
  controller.authorize_resource

  index do
    column :name
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :name
    end
    f.globalize_inputs :translations do |lf|
      lf.inputs do
        # lf.input :title
        lf.input :body
        lf.input :locale, :as => :hidden
      end
    end
    f.buttons
  end

  filter :name
end
