class WuozNotification < ActiveRecord::Base
  attr_accessible :alert_ids, :body, :subject, :wuoz_agency_id, :zip_file
  belongs_to :wuoz_agency
  serialize(:alert_ids, Array)

  validates :subject, :body, :wuoz_agency_id, :presence => true
  after_create :send_notification

  def alert_ids=(value)
    if value.is_a?(Array)
      self[:alert_ids] = value
    else
      self[alert_ids] = value.to_s.split(',').reject(&:blank?)
    end
  end

  def alerts
    Alert.where(:id => alert_ids)
  end

  def wuoz_agency_id=(value)
    self[:wuoz_agency_id] = value
    self.alert_ids = self.wuoz_agency.wuoz_alerts.not_sent.pluck(:alert_id)
  end

  def prepare_zip_file
    # TODO
  end

  def mark_alerts_as_sent
    self.wuoz_agency.wuoz_alerts.not_sent.update_all(['sent_at = ?', Time.now])
  end

  # TODO put in to resque
  def send_notification
    prepare_zip_file
    mark_alerts_as_sent
    AlertMailer.notify_wuoz(self.id)
  end

end
