# -*- encoding : utf-8 -*-
class Place < ActiveRecord::Base
  attr_accessible :id, :name, :commune_id, :sym, :from_teryt
  belongs_to :commune
  has_many :relics, :dependent => :destroy

  validates :name, :presence => true

  scope :not_custom, where(:custom => false)

  def virtual_commune_id
    self[:virtual_commune_id] || self.commune_id
  end

end
