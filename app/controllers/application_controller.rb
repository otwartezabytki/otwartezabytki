# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :page_pl_path, :search_params, :tsearch

  before_filter do
    if current_user.present? && current_user.username.blank?
      sign_out current_user
    end
  end

  def page_pl_path(path)
    "/strony/#{path}"
  end

  def tsearch
    return @tsearch if defined? @tsearch
    @tsearch = Search.new search_params(:page => params[:page])[:search]
  end

  def search_params opt = {}
    cond = params[:search] || {}
    { :search => cond.merge(opt) }
  end
end
