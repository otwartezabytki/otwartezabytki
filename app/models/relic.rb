class Relic < ActiveRecord::Base
  include Importer
  attr_accessible :dating_of_obj, :group, :id, :identification, :materail, :national_number, :number, :place_id, :register_number, :street
end
