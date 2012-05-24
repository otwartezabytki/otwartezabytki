# -*- encoding : utf-8 -*-
require 'rubygems'
require 'spork'
require 'database_cleaner'
require 'factory_girl'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.mock_with :rspec
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = true

    # Needed for Spork
    ActiveSupport::Dependencies.clear
  end
  DatabaseCleaner.strategy = :truncation
end

Spork.each_run do
  DatabaseCleaner.clean
  FactoryGirl.reload
  load "#{Rails.root}/config/routes.rb"
  Dir["#{Rails.root}/app/**/*.rb"].each { |f| load f }
  I18n.backend.reload!
end

def sample_path file
  file_path = "#{Rails.root}/spec/samples/#{file}"
  raise Exception.new("File not found: #{file_path}") unless File.exists?(file_path)
  file_path
end
