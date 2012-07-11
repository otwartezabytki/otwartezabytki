# config/initializers/geocoder.rb
Geocoder.configure do |config|

  # geocoding service (see below for supported options):
  config.lookup = :google

  # to use an API key:
  config.api_key = Settings.oz.gm_key

  # geocoding service request timeout, in seconds (default 3):
  config.timeout = 5

  # set default units to kilometers:
  config.units = :km

  # caching (see below for details):
  config.cache = Dalli::Client.new  unless ['test', 'development'].include?(Rails.env)

end
