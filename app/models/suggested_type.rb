# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: suggested_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SuggestedType < ActiveRecord::Base
  attr_accessible :name, :as => :admin

  validate :name, :presence => true, :unique => true
end
