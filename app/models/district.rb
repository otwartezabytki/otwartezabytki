# -*- encoding : utf-8 -*-
class District < ActiveRecord::Base
  attr_accessible :id, :name, :voivodeship_id
  belongs_to :voivodship
  has_many :communes, :dependent => :destroy
  has_many :places, :through => :communes

  validates :name, :presence => true
end
