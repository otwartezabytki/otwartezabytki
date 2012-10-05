class WuozRegion < ActiveRecord::Base
  attr_accessible :district_id, :wuoz_agency_id
  belongs_to :district
  belongs_to :wuoz_agency
end
