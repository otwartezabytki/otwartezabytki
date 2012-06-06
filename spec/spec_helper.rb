# -*- encoding : utf-8 -*-
require 'rubygems'
require 'spork'
require 'database_cleaner'
require 'factory_girl'

require 'spec_helper/elastic_search'
require 'spec_helper/decent_exposure'

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

    # Factory girl
    config.include FactoryGirl::Syntax::Methods

    # Clear search index for each test
    config.before(:each) do
      refresh_relics_index
    end
  end
  DatabaseCleaner.strategy = :truncation
end

Spork.each_run do
  DatabaseCleaner.clean
  FactoryGirl.reload
  I18n.backend.reload!
end

def sample_path file
  file_path = "#{Rails.root}/spec/samples/#{file}"
  raise Exception.new("File not found: #{file_path}") unless File.exists?(file_path)
  file_path
end
