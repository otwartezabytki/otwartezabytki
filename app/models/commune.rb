class Commune < ActiveRecord::Base
  attr_accessible :id, :name, :district_id
  belongs_to :district
  has_many :places, :dependent => :destroy
end
