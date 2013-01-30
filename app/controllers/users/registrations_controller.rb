# -*- encoding : utf-8 -*-
class Users::RegistrationsController < ApplicationController

  skip_before_filter :save_return_path

  before_filter :enable_fancybox

  respond_to :html

  expose(:user)

  def new
    render :new
  end

  def edit
    render :edit
  end

  def create
    if user.save
      flash[:notice] = t('notices.reservation_thanks')
      user.send(:generate_reset_password_token!)
      UserMailer.welcome_email(user, user.password, user.reset_password_token).deliver
      sign_in user, :bypass => true
      respond_with user, :location => after_update_path_for(user)
    else
      respond_with user
    end
  end

  protected

  def after_update_path_for(resource)
    hello_path
  end

end
