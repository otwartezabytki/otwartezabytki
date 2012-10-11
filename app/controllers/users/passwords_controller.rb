# -*- encoding : utf-8 -*-
class Users::PasswordsController < Devise::PasswordsController

  before_filter :enable_fancybox

  skip_before_filter :require_no_authentication

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_navigational_format?
      warden.set_user resource
      sign_in(resource_name, resource, :bypass => true)
      respond_with resource, :location => hello_path(:notification => "password")
    else
      respond_with resource
    end
  end
end
