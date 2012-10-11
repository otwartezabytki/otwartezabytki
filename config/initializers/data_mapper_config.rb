# -*- encoding : utf-8 -*-
# A MySQL connection:
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite:///#{Rails.root}/vendor/relics_cleanup.db")
DataMapper::Property::String.length(255)
