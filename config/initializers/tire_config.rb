# -*- encoding : utf-8 -*-
require 'curb'
require 'tire/http/clients/curb'

Tire.configure do
  logger  'log/elasticsearch.log'
  client  Tire::HTTP::Client::Curb
end
