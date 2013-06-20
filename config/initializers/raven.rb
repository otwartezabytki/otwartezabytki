# -*- encoding : utf-8 -*-
require 'raven'
Raven.configure do |config|
  config.dsn = Settings.raven_dsn
end