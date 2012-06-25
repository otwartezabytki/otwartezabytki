# encoding: utf-8
class Users::RegistrationsController < ApplicationController
  respond_to :html
  before_filter :current_user!

  # GET /resource/edit
  def edit
    render :edit
  end

  # PUT /resource
  # We need to use a copy of the resource because we don't want to change
  # the current user in place.
  def update
    if current_user.update_attributes(params[:user])
      sign_in current_user, :bypass => true
      flash[:notice] = "Dziękujemy za rejestrację! Na podany e-mail zostało wysłane Twoje hasło. Tymczasem zachęcamy do dalszego poprawiania zabytków:"
      respond_with current_user, :location => after_update_path_for(current_user)
    else
      respond_with current_user
    end
  end

  protected

  # The default url to be used after updating a resource. You need to overwrite
  # this method in your own RegistrationsController.
  def after_update_path_for(resource)
    Relic.next_for(resource)
  end

end
