# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :page_pl_path, :search_params, :tsearch
  # iframe views path
  before_filter do
    prepend_view_path("app/views/iframe") if Subdomain.matches?(request)
  end

  before_filter do
    # set locale
    if params[:locale] and Settings.oz.locale.available.include?(params[:locale].to_sym)
      cookies[:locale] = params[:locale]
      I18n.cache_store.clear
    end
    I18n.locale = (cookies[:locale] || current_user.try(:default_locale) || I18n.default_locale).to_sym
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
    response.headers['x-csrf-token'] = form_authenticity_token unless request.get?
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
    @tsearch = Search.new search_params(:page => params[:page], :load => true)[:search]
  end

  def search_params opt = {}
    cond = (params[:search] || {}).inject(HashWithIndifferentAccess.new) {|m, (k,v)| m[k] = v if v.present?; m}
    { :search => cond.merge(opt.with_indifferent_access) }.with_indifferent_access
  end

  def enable_fancybox
    if request.xhr?
      response.headers['x-fancybox'] = 'true'
    elsif respond_to?('fancybox_root')
      redirect_to(fancybox_root, :anchor => request.fullpath)
    end
  end

  def enable_floating_fancybox
    response.headers['x-float'] = 'true' if request.xhr?
  end

  def render404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404.html", :layout => false, :status => :not_found }
      format.any  { head :not_found }
    end
  end

  protected

  def save_return_path
    cookies[:return_path] = request.fullpath if request.get?
  end

  def authenticate_admin!
    authenticate_user!
    raise CanCan::AccessDenied unless current_user.try(:admin?)
  end

  private

  def after_sign_in_path_for(resource)
    cookies.delete(:return_path) if Subdomain.matches?(request)
    stored_location_for(resource) || cookies[:return_path] || relics_path
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
