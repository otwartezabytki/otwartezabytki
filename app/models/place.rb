# -*- encoding : utf-8 -*-
class Place < ActiveRecord::Base
  attr_accessible :id, :name, :commune_id
  belongs_to :commune
  has_many :relics, :dependent => :destroy

  validates :name, :presence => true
end
