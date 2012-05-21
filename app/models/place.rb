class Place < ActiveRecord::Base
  attr_accessible :id, :name, :commune_id
  belongs_to :commune
end
