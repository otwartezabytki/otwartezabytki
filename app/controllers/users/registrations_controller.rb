# -*- encoding : utf-8 -*-
class Users::RegistrationsController < ApplicationController
  respond_to :html
  before_filter :enable_fancybox
  expose(:user)

  def new
    render :new
  end

  def edit
    render :edit
  end

  def create
    if user.save
      flash[:notice] = cookies[:return_path] ? t('notices.reservation_thanks_short') : t('notices.reservation_thanks')
      user.send(:generate_reset_password_token!)
      UserMailer.welcome_email(user, user.password, user.reset_password_token).deliver
      sign_in user, :bypass => true
      respond_with user, :location => cookies.delete(:return_path) || after_update_path_for(user)
    else
      respond_with user
    end
  end

  protected

  def after_update_path_for(resource)
    hello_path
  end

  def devise_controller?
    true
  end

end
