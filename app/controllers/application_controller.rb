# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter do
    I18n.locale = :pl
  end

  def current_user!
    unless user_signed_in?
      sign_in User.create!
    end
   
    current_user
  end
end
