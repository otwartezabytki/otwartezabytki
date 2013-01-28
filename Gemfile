source 'https://rubygems.org'

gem 'rails', '~> 3.2.3', git: 'git://github.com/sheerun/rails.git', branch: 'v3.2.11/multipart-fix'
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
gem 'formtastic'
gem 'formtastic-bootstrap'

gem 'decent_exposure'
gem 'kaminari'
gem 'ancestry'
gem 'tire', '0.4.3'
gem 'tire-contrib'
gem 'rocket_tag'
gem 'airbrake'

gem 'paper_trail', '~> 2' # versioning

# admin panel
gem 'activeadmin',    '~> 0.4.4'
gem 'meta_search',    '>= 1.1.0.pre'
gem 'devise'
gem 'omniauth-facebook'
gem 'cancan'
gem 'activeadmin-cancan'

gem 'yajl-ruby',    '1.1.0',  :require => 'yajl'
gem 'multi_json',   '1.3.7'
gem 'remote_table'

gem 'unicode'
gem 'gon'
gem 'rails_config', '0.2.5'
gem 'dalli'
gem 'will_cache'
gem 'arrabiata' # roman letters converter
gem 'rails-i18n'
gem 'i18n-country-translations'
gem 'i18n_country_select', '~> 1.0.14'

gem 'whenever', :require => false               # cron jobs
gem 'recaptcha', :require => 'recaptcha/rails'  # bot secrity

# file upload
gem 'carrierwave'
gem 'carrierwave-meta'
gem 'mini_magick', :git => "git://github.com/gmanley/mini_magick.git", :branch => "graphicsmagick-fix"

gem 'gravatar_image_tag'  # gravatars
gem 'wicked'              # relicbuilder wizard
gem 'js-routes'           # rails routes in javascirpt
gem 'acts_as_list'        # sorting links and relic events
gem 'rubyzip'             # download documents as zip
gem 'aasm'                # state machine
gem 'http_accept_language', :git => "git://github.com/zzet/http_accept_language.git"

# api
gem "jbuilder"

gem 'htmldiff'                # diff changes in admin panel
gem 'friendly_id'             # friendly id for widgets
gem 'turbo-sprockets-rails3'  # faster asset precompiling

gem 'globalize3'
gem 'activeadmin-globalize3-inputs', :git => 'git://github.com/chytreg/activeadmin-globalize3-inputs.git'

gem 'ffi-aspell', :require => 'ffi/aspell', :git => 'git://github.com/chytreg/ffi-aspell.git'
gem 'tolk', :git => "git://github.com/monterail/tolk.git", :branch => "oz-custom"

gem 'foreman'
gem 'twitter_cldr'

# documentation
gem 'yard'
gem 'redcarpet'

group :development, :test do
  gem 'interactive_editor'
  gem 'ruby-debug19'        # for debugging
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'sextant'             # for routes in /rails/routes
  gem 'annotate', ">=2.5.0" # for annotating db schema in models
  gem 'quiet_assets'
  gem 'zeus'
  gem 'guard-ctags-bundler'
end

group :production do
  gem 'therubyracer' # assets javascript compiler
  gem 'newrelic_rpm', '~> 3.5.5.38'
end

group :test do
  # for defining tests
  gem 'rspec-rails',  '~> 2.0'
  gem 'factory_girl_rails'
  gem 'forgery', '0.5.0'
  gem 'database_cleaner'
  gem 'capybara'

  # for running tests
  gem 'guard'
  gem 'guard-rspec'
  gem 'growl'
  gem 'rb-fsevent'

  gem 'shoulda-matchers'
  gem 'simplecov', :require => false
end
