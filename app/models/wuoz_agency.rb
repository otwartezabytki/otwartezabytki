class WuozAgency < ActiveRecord::Base
  attr_accessible :city, :director, :email, :address, :district_names, :wuoz_key
  has_many :wuoz_regions
  has_many :districts, :through => :wuoz_regions
  has_many :wuoz_alerts
  has_many :alerts, :through => :wuoz_alerts
  has_many :wuoz_notifications

  scope :only_with_alerts, joins(:wuoz_alerts).where('wuoz_alerts.sent_at IS NULL').group('wuoz_agencies.id').having('COUNT(alert_id) > 0')

  class << self
    def seed!
      # truncate
      connection.execute("TRUNCATE #{self.table_name};")
      hash = JSON.parse(File.open("#{Rails.root}/db/json/wuoz-agencies.json").read)
      hash.each do |key, obj|
        obj['agencies'].each do |attrs|
          agency = self.create attrs.merge('wuoz_key' => key)
          agency.seed_wouz_regions
        end
      end
      true
    end
  end

  def wuoz_name
    I18n.t("wuoz.#{wuoz_key}")
  end

  def alerts_count
    @alerts_count ||= wuoz_alerts.not_sent.count
  end

  def seed_wouz_regions
    district_names.split(',').map do |name|
      results = District.where(['name = ?', name.strip])
      Rails.logger.error "Cant find #{id}: #{name}" if results.blank?
      results.each do |r|
        WuozRegion.find_or_create_by_wuoz_agency_id_and_district_id(self.id, r.id)
      end
    end.compact.flatten
    true
  end

end
