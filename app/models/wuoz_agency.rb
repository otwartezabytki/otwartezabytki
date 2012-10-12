# -*- encoding : utf-8 -*-
class WuozAgency < ActiveRecord::Base
  attr_accessible :city, :director, :email, :address, :district_names, :wuoz_key
  has_many :wuoz_regions
  has_many :districts, :through => :wuoz_regions
  has_many :wuoz_alerts
  has_many :alerts, :through => :wuoz_alerts
  has_many :wuoz_notifications

  scope :only_with_alerts, joins(:wuoz_alerts).where('wuoz_alerts.sent_at IS NULL').group('wuoz_agencies.id').having('COUNT(alert_id) > 0')

  def wuoz_name
    I18n.t("wuoz.#{wuoz_key}")
  end

  def alerts_count
    @alerts_count ||= wuoz_alerts.not_sent.count
  end
end
