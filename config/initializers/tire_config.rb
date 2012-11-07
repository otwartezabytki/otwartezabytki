# -*- encoding : utf-8 -*-
require 'tire/http/clients/faraday'

Tire.configure do |config|
  logger  'log/elasticsearch.log'

  # Unless specified, tire will use Faraday.default_adapter and no middleware
  Tire::HTTP::Client::Faraday.faraday_middleware = Proc.new do |builder|
    builder.adapter :net_http
  end

  config.client(Tire::HTTP::Client::Faraday)
end