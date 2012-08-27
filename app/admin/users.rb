ActiveAdmin.register User do
  controller.authorize_resource

  filter :id
  filter :email
  filter :created_at
  filter :api_key

  index do
    column :id
    column :email
    column :role
    column :created_at
    default_actions
  end


  form do |f|

    f.inputs do
      f.input :email
      f.input :role, :collection => [:admin, :user], :include_blank => true
    end

    f.actions
  end


  member_action :generate_api_secret, :method => :put do
    @user = User.find(params[:id])
    @user.generate_api_secret!
    @user.save

    redirect_to admin_user_path(@user.id)
  end

  action_item :only => :show  do
    link_to t('buttons.generate_api_secret'), generate_api_secret_admin_user_path(resource), :method => :put
  end


end
