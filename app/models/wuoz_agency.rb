# -*- encoding : utf-8 -*-
class WuozAgency < ActiveRecord::Base
  attr_accessible :city, :director, :email, :address, :district_names, :wuoz_key
  has_many :wuoz_regions, :dependent => :destroy
  has_many :districts, :through => :wuoz_regions
  has_many :wuoz_alerts, :dependent => :destroy
  has_many :alerts, :through => :wuoz_alerts
  has_many :wuoz_notifications, :dependent => :destroy

  scope :only_with_alerts, where(:id => WuozAlert.not_sent.group('wuoz_agency_id').having('COUNT(alert_id) > 0').select(:wuoz_agency_id))

  def wuoz_name
    I18n.t("wuoz.#{wuoz_key}")
  end

  def alerts_count
    @alerts_count ||= wuoz_alerts.not_sent.count
  end
end
