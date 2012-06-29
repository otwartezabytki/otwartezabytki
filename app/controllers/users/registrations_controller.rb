# encoding: utf-8
class Users::RegistrationsController < ApplicationController
  respond_to :html
  before_filter :current_user!

  def new
    render :edit
  end

  def edit
    render :edit
  end

  def create
    update
  end

  def update
    if current_user.update_attributes(params[:user])
      flash[:notice] = t('notices.reservation_thanks')
      current_user.send(:generate_reset_password_token!)
      UserMailer.welcome_email(current_user, current_user.password, current_user.reset_password_token).deliver
      sign_in current_user, :bypass => true
      respond_with current_user, :location => after_update_path_for(current_user)
    else
      respond_with current_user
    end
  end

  protected

  def after_update_path_for(resource)
    Relic.next_for(resource)
  end

end