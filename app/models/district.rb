class District < ActiveRecord::Base
  attr_accessible :id, :name, :voivodship_id
  belongs_to :voivodship
  has_many :communes, :dependent => :destroy
  has_many :places, :through => :communes
end
