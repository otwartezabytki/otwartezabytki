class Users::SessionsController < Devise::SessionsController

  skip_before_filter :require_no_authentication

  # POST /resource/sign_in
  def create

    logged_user = warden.user
    warden.set_user nil

    if resource = warden.authenticate(auth_options)

      set_flash_message(:notice, :signed_in) if is_navigational_format?
      sign_in(resource_name, resource)

      # rewrite all suggestions to newly logged in user and remove old one
      if logged_user && logged_user.email.blank?
        resource.suggestions += logged_user.suggestions

        if resource.save
          logged_user.destroy
        end
      end

      respond_with resource, :location => after_sign_in_path_for(resource)
      
    else
      flash[:error] = t("devise.failure.invalid")

      if logged_user
        warden.set_user logged_user
        sign_in logged_user, :bypass => true
      end

      throw(:warden)
    end

  end
end