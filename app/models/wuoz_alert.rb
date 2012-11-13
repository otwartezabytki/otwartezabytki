# -*- encoding : utf-8 -*-
class WuozAlert < ActiveRecord::Base
  attr_accessible :alert_id, :sent_at, :wuoz_agency_id
  belongs_to :alert
  belongs_to :wuoz_agency

  scope :not_sent, where('sent_at IS NULL')
end
