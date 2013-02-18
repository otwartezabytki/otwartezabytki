# -*- encoding : utf-8 -*-
class UsersController < ApplicationController

  authorize_resource :decent_exposure => true

  expose(:user)

  expose(:added_relics) do
    Relic.where(:user_id => user.id)
  end

  expose(:checked_relics) do
    Relic.where(:id => Suggestion.select(:id).where(:user_id => user.id).map(&:relic_id))
  end

  def update
    if current_user.update_with_password(params[:user])
      redirect_to user, :notice => I18n.t("notices.profile_updated")
    else
      render :edit
    end
  end

  def remove_avatar
    user.remove_avatar!
    redirect_to edit_user_path(user)
  end
end
