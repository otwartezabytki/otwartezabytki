# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :page_pl_path, :search_params, :tsearch

  around_filter :intersect_warden

  def intersect_warden
    success = false
    result = catch(:warden) do
      result = yield
      success = true
      result
    end

    unless success
      cookies[:return_path] = request.fullpath
      throw(:warden, result)
    end
  end

  # disabling because it doesn't work with history back when page is retrieved from cache
  layout :resolve_layout
  def resolve_layout
    if request.xhr?
      'ajax'
    elsif Subdomain.matches?(request)
      'iframe'
    else
      'application'
    end
  end


  # for logging out anonymous users
  before_filter do
    if current_user.present? && current_user.username.blank?
      sign_out current_user
    end
  end

  # for ajax history management
  before_filter do
    response.headers['x-path'] = request.fullpath
  end

  after_filter do
    response.headers['x-logged'] = warden.authenticated?.to_s
  end

  rescue_from CanCan::AccessDenied do |exception|
    if current_user
      redirect_to root_path, :notice => exception.message
    else
      redirect_to new_user_session_path, :notice => exception.message
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
    cond = (params[:search] || {}).inject(HashWithIndifferentAccess.new) {|m, (k,v)| m[k] = v if v.present?; m}
    { :search => cond.merge(opt.with_indifferent_access) }.with_indifferent_access
  end

  def enable_fancybox
    response.headers['x-fancybox'] = 'true' if request.xhr?
  end

  def render404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404.html", :layout => false, :status => :not_found }
      format.any  { head :not_found }
    end
  end

  private

  def after_sign_in_path_for(resource)
    cookies.delete(:return_path) if Subdomain.matches?(request)
    stored_location_for(resource) || cookies.delete(:return_path) || relics_path
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource)
    cookies.delete(:last_relic_id) if Subdomain.matches?(request)
    if relic_id = cookies.delete(:last_relic_id)
      relic_path(relic_id)
    else
      relics_path
    end
  end
end
