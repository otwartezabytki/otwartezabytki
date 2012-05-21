class Voivodeship < ActiveRecord::Base
  attr_accessible :id, :name
  has_many :districts, :dependent => :destroy
  has_many :communes, :through => :districts
  has_many :places, :through => :communes
end
