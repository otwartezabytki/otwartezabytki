# -*- encoding : utf-8 -*-
class Commune < ActiveRecord::Base
  attr_accessible :id, :name, :district_id, :nr, :kind
  belongs_to :district
  has_many :places, :dependent => :destroy

  validates :name, :presence => true

end
