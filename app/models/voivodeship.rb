# -*- encoding : utf-8 -*-
class Voivodeship < ActiveRecord::Base
  attr_accessible :id, :name, :nr
  has_many :districts, :dependent => :destroy
  has_many :communes, :through => :districts
  has_many :places, :through => :communes
  has_many :relics, :through => :places

  validates :name, :presence => true

  def name
    self[:name].downcase
  end

end
