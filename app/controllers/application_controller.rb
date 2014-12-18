# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :search_params, :tsearch, :enabled_locales, :iframe_transport?, :js_env, :angular_js_env, :with_return_path
  # iframe views path
  before_filter do
    prepend_view_path("app/views/iframe") if Subdomain.matches?(request)
  end

  before_filter do
    # set locale
    locale = params[:locale] if params[:locale] and enabled_locales.include?(params[:locale].to_sym)
    I18n.locale = (
      locale ||
      cookies[:locale] ||
      current_user.try(:language) ||
      # disable for now
      # http_accept_language.compatible_language_from(enabled_locales) ||
      I18n.default_locale
    ).to_sym
    cookies[:locale] = I18n.locale
  end

  before_filter :save_return_path

  # disabling because it doesn't work with history back when page is retrieved from cache
  layout :resolve_layout
  def resolve_layout
    if request.xhr? or iframe_transport?
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

  def tsearch
    return @tsearch if defined? @tsearch
    @tsearch = Search.new search_params(:page => params[:page], :load => true)[:search]
  end

  def search_params opt = {}
    cond = (params[:search] || {}).inject(HashWithIndifferentAccess.new) {|m, (k,v)| m[k] = v if v.present?; m}
    { :search => cond.merge(opt.with_indifferent_access) }.with_indifferent_access
  end

  def enable_fancybox
    if request.xhr? or iframe_transport?
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

  def default_url_options(options = {})
    { :locale => I18n.locale }
  end

  def enabled_locales
    Settings.oz.locale.to_hash[(current_user.try(:admin?) ? :available : :enabled)]
  end

  def iframe_transport?
    request.params['X-Requested-With'] == 'IFrame'
  end

  def iframe_url_options
    { 'X-Requested-With' => 'IFrame' } if iframe_transport?
  end

  def set_return_path(path)
    cookies[:return_path] = path
  end

  def js_env_data
    {
      development: Rails.env.development?
    }.to_json
  end

  def js_env
    <<-EOS
    var envConfig = #{js_env_data}
    EOS
  end

  def angular_js_env
    <<-EOS
    this.app.constant("envConfig", #{js_env_data})
    EOS
  end

  def with_return_path
    nil
  end

  protected

  def save_return_path
    return false if (devise_controller? && params[:return_path].blank?) || request.format == 'json' || params[:iframe] || params[:skip_return_path]
    set_return_path(params[:return_path].presence || request.fullpath) if request.get?
  end

  def authenticate_admin!
    authenticate_user!
    raise CanCan::AccessDenied unless current_user.try(:admin?)
  end

  private

  def after_sign_in_path_for(resource)
    cookies.delete(:return_path) || relics_path
  end

  def after_sign_out_path_for(resource)
    cookies.delete(:return_path) if Subdomain.matches?(request)
    cookies.delete(:return_path) || root_path
  end
end
