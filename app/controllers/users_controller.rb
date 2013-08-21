# -*- encoding : utf-8 -*-
class UsersController < ApplicationController

  authorize_resource :decent_exposure => true

  expose(:user, strategy: StrongParametersStrategy)

  expose(:added_relics) do
    Relic.where(:user_id => user.id)
  end

  expose(:checked_relics) do
    Relic.where(:id => Suggestion.select(:id).where(:user_id => user.id).map(&:relic_id))
  end

  expose(:my_routes) do
    Widget::Direction.where(user_id: user.id)
  end

  def update
    successfully_updated = if needs_password?(user, params)
      user.update_with_password(user_params(true))
    else
      user.update_without_password(user_params(true))
    end

    if successfully_updated
      redirect_to edit_user_path(user), :notice => I18n.t("notices.profile_updated")
    else
      flash.now[:error] = I18n.t("notices.profile_not_updated")
      render :edit
    end
  end

  def remove_avatar
    user.remove_avatar!
    redirect_to edit_user_path(user)
  end

  private

  def user_params(include_password = false)
    if include_password
      params.require(:user).permit(
        :email, :password, :password_confirmation,
        :username, :avatar, :language, :current_password
      )
    else
      params.require(:user).permit(
        :email, :username, :avatar, :language
      )
    end

  end

  # check if we need password to update user data
  def needs_password?(user, params)
    user.email != params[:user][:email] || !params[:user][:password].blank?
  end
end
