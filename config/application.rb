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

module Otwartezabytki
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    #config.autoload_paths += %W(#{config.root}/lib)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Warsaw'

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.default_locale = config.i18n.locale = I18n.locale = :pl

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # generators
    config.generators do |g|
      g.template_engine       :haml
      g.test_framework        :rspec, :fixture => true, :view_specs => false
      g.fixture_replacement   :factory_girl, :dir => "spec/factories"
      g.stylesheets           false
      g.javascripts           false
    end
    unless ['test', 'development'].include?(Rails.env)
      # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
      config.assets.precompile += %w( active_admin.js wizard.js ie8.css profile.js )
      config.cache_store = :dalli_store, { :namespace => "otwartezabytki-#{Rails.env}", :expires_in => 1.day, :compress => true }
    end

    config.action_mailer.default_url_options = { :host => Settings.oz.host }

    config.action_view.sanitized_allowed_tags = ['table', 'tr', 'td', 'strong', 'em', 'li', 'ul', 'ol', 'a', 'p', 'div']
  end
end
