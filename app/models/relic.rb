# -*- encoding : utf-8 -*-
class Relic < ActiveRecord::Base
  attr_accessible :dating_of_obj, :group, :id, :identification, :materail, :national_number, :number, :place_id, :register_number, :street, :internal_id, :source
  belongs_to :place

  validates :place_id, :presence => true

  has_ancestry
  serialize :source

end
