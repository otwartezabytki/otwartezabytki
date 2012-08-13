# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :page_pl_path, :search_params, :tsearch

  # disabling because it doesn't work with history back when page is retrieved from cache
  layout :resolve_layout
  def resolve_layout
    if request.xhr?
      'ajax'
    else
      'application'
    end
  end

  # for ajax history management
  before_filter do
    response.headers['x-path'] = request.fullpath
  end

  # for logging out anonymous users
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
