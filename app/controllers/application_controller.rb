# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter do
    I18n.locale = I18n.default_locale
  end
  helper_method :page_pl_path

  def current_user!
    unless user_signed_in?
      sign_in User.create!
    end

    current_user
  end

  def page_pl_path(path)
    "/strony/#{path}"
  end
end
