# -*- encoding : utf-8 -*-
class Place < ActiveRecord::Base
  attr_accessible :id, :name, :commune_id, :sym
  belongs_to :commune
  has_many :relics, :dependent => :destroy

  validates :name, :presence => true

  def full_name
    [commune.district.voivodeship.name, commune.district.name, commune.name, name].join(', ')
  end

end
