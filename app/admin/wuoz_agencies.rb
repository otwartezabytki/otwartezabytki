# encoding: utf-8

ActiveAdmin.register WuozAgency do
  menu :label => "Delegatury NID"

  controller.authorize_resource

  index do
    column :city
    column :director
    column :email
    column :address
    column :districts
    column :wuoz_name
    default_actions
  end

  # form do |f|
  #   f.inputs do
  #     f.input :relic_id
  #     f.input :name
  #     f.input :description
  #     f.input :file
  #     f.buttons
  #   end

  # end

  # filter :id
  # filter :relic_id, :as => :numeric
  # filter :name
  # filter :description
end
