# -*- encoding : utf-8 -*-
require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

require 'tire/rails/logger'
require 'zip/zip'
require 'yajl/json_gem'

module Otwartezabytki
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/lib #{config.root}/app/strategies)
    ActiveSupport::Dependencies.explicitly_unloadable_constants << 'Polygon'

    config.time_zone = 'Warsaw'

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.default_locale = config.i18n.locale = I18n.locale = :pl
    config.i18n.available_locales = Settings.oz.locale.available
    config.i18n.fallbacks = true

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = false

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.3'

    # generators
    config.generators do |g|
      g.template_engine       :haml
      g.test_framework        :rspec, :fixture => true, :view_specs => false
      g.fixture_replacement   :factory_girl, :dir => "spec/factories"
      g.stylesheets           false
      g.javascripts           false
    end
    config.assets.paths << "#{Rails.root}/app/assets/fonts"
    config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/
    unless ['test', 'development'].include?(Rails.env)
      # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
      config.assets.precompile += %w( active_admin.js ie8.css iframe.css print.css widgets/* )
      config.cache_store = :dalli_store, { :namespace => "otwartezabytki-#{Rails.env}-#{Digest::MD5.hexdigest(Rails.root.to_s[0..31])}", :expires_in => 1.day, :compress => true }
    end

    config.action_mailer.default_url_options = { :host => Settings.oz.host }

    config.action_view.sanitized_allowed_tags = ['table', 'tr', 'td', 'strong', 'em', 'li', 'ul', 'ol', 'a', 'p', 'div', 'del', 'ins']
  end
end
