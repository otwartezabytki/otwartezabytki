source 'https://rubygems.org'

gem 'rails', '~> 3.2.3'

gem 'pg'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'compass-rails'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'chosen-rails'
  gem 'jquery-ui-rails'
  gem 'twitter-bootstrap-rails'
  gem 'bootstrap-sass', '~> 2.0.4.0'
end

gem 'jquery-rails'
gem 'haml-rails'
gem 'coffee-filter'
gem 'sugar-rails'

gem 'geocoder'
gem 'simple_form', '~> 2.0'
gem 'formtastic'
gem 'formtastic-bootstrap'

gem 'decent_exposure'
gem 'kaminari'
gem 'ancestry'
gem 'curb'
gem 'tire', '0.4.2'
gem 'tire-contrib'
gem 'rocket_tag'
gem 'airbrake'

# versioning
gem 'paper_trail', '~> 2'

# admin panel
gem 'activeadmin',    '~> 0.4.4'
gem 'meta_search',    '>= 1.1.0.pre'
gem 'devise'
gem 'cancan'
gem 'activeadmin-cancan'

gem 'multi_json', '~> 1.0.3'
gem 'json', '~> 1.5.4'
gem 'remote_table'

# import data from sqlite
gem 'data_mapper', '~> 1.2'
gem 'dm-chunked_query'
gem 'dm-sqlite-adapter'
gem 'unicode'
gem 'gon'
gem 'high_voltage'
gem 'newrelic_rpm'
gem 'rails_config', '0.2.5'
gem 'dalli'
gem 'will_cache'
# roman letters converter
gem 'arrabiata'
gem 'rails-i18n'
gem 'i18n-country-translations'
gem 'i18n_country_select'

# background jobs
gem 'whenever', :require => false

# bot secrity
gem 'recaptcha', :require => 'recaptcha/rails'

# file upload
gem 'carrierwave'
gem 'carrierwave-meta'
gem 'mini_magick', :git => "git://github.com/gmanley/mini_magick.git", :branch => "graphicsmagick-fix"

# gravatars
gem 'gravatar_image_tag'

# api
gem 'rabl'

# wizard
gem 'wicked'

# rails routes in javascirpt
gem 'js-routes'

# sorting links and relic events
gem 'acts_as_list'

# download documents as zip
gem 'rubyzip'

# state machine
gem 'aasm'

# api
gem "jbuilder"

# diff changes in admin panel
gem 'htmldiff'

# friendly id for widgets
gem 'friendly_id'

# faster asset precompiling
gem 'turbo-sprockets-rails3'
gem 'rubyzip'

group :development, :test do
  # for debugging
  gem 'ruby-debug19'
  gem 'pry-rails'
  gem 'pry-doc'
  # for routes in /rails/routes
  gem 'sextant'
  gem 'guard-cucumber'

  # for annotating db schema in models
  gem 'annotate', ">=2.5.0"
  gem 'quiet_assets'
end

# assets javascript compiler
gem 'therubyracer', :group => :production

gem 'ffi-aspell', :require => 'ffi/aspell'

gem 'tolk', :git => "git://github.com/monterail/tolk.git"#, :path => '~/monterail/tolk'

group :test do
  # for defining tests
  gem 'cucumber-rails', :require => false
  gem 'rspec-rails',  '~> 2.0'
  gem 'factory_girl_rails'
  gem 'forgery', '0.5.0'
  gem 'database_cleaner'
  gem 'capybara'

  # for running tests
  gem 'spork-rails'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'growl'
  gem 'rb-fsevent'

  gem 'shoulda-matchers'
  gem 'simplecov', :require => false
end
