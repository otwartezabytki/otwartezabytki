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
      sign_in current_user, :bypass => true
      flash[:notice] = t('notices.reservation_thanks')
      UserMailer.welcome_email(current_user, current_user.password).deliver
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