# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :page_pl_path

  def page_pl_path(path)
    "/strony/#{path}"
  end

  before_filter do
    if current_user.present? && current_user.username.blank?
      sign_out current_user
    end
  end
end
