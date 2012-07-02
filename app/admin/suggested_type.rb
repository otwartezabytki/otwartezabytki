ActiveAdmin.register SuggestedType do
  controller.authorize_resource

  index do
    column :name
    default_actions
  end

end
