class SuggestedType < ActiveRecord::Base
  attr_accessible :name, :as => :admin

  validate :name, :presence => true, :unique => true
	
end
