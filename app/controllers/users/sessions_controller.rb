class Users::SessionsController < Devise::SessionsController

  before_filter :enable_fancybox

  # POST /resource/sign_in
  def create
    resource = warden.authenticate!(auth_options)
    # disable flash message
    # set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    respond_with resource, :location => after_sign_in_path_for(resource)
  end

  # anonymus user support
  # def create
  #   logged_user = warden.user
  #   warden.set_user nil
  #   if resource = warden.authenticate(auth_options)
  #     set_flash_message(:notice, :signed_in) if is_navigational_format?
  #     sign_in(resource_name, resource)
  #     # rewrite all suggestions to newly logged in user and remove old one
  #     if logged_user && logged_user.email.blank?
  #       resource.suggestions += logged_user.suggestions
  #       if resource.save
  #         logged_user.destroy
  #       end
  #     end
  #     respond_with resource, :location => after_sign_in_path_for(resource)
  #   else
  #     flash[:error] = t("devise.failure.invalid")
  #     if logged_user
  #       warden.set_user logged_user
  #       sign_in logged_user, :bypass => true
  #     end
  #     throw(:warden)
  #   end
  # end

  # DELETE /resource/sign_out
  def destroy
    redirect_path = after_sign_out_path_for(resource_name)
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    # disable flash message
    # set_flash_message :notice, :signed_out if signed_out

    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.any(*navigational_formats) { redirect_to redirect_path }
      format.all do
        head :no_content
      end
    end
  end
end

