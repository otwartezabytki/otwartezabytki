# -*- encoding : utf-8 -*-
# config/initializers/geocoder.rb
Geocoder.configure(
  # geocoding service (see below for supported options):
  :lookup => :google,

  # to use an API key:
  # :api_key => "...",

  # geocoding service request timeout, in seconds (default 3):
  :timeout => 5,

  # set default units to kilometers:
  :units => :km,

  # language
  :language => :pl
)
