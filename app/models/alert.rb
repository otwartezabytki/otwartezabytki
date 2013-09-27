# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: alerts
#
#  id          :integer          not null, primary key
#  relic_id    :integer
#  user_id     :integer
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  file        :string(255)
#  state       :string(255)
#

class Alert < ActiveRecord::Base
  belongs_to :relic
  belongs_to :user

  attr_accessible :relic_id, :user_id, :file, :description, :author, :date_taken
  attr_accessible :relic_id, :user_id, :file, :description, :author, :date_taken, :state, :as => :admin

  has_many :wuoz_alerts, :dependent => :destroy

  after_create :new_alert_notification
  after_create :create_wuoz_alert

  validates :description, :presence => true

  scope :fixed, where("state = ?", "fixed")
  scope :not_fixed, where("state != ? or state is null", "fixed")

  mount_uploader :file, AlertUploader

  class << self
    def logger
      @logger ||= Logger.new("#{Rails.root}/log/cant_find_wuoz_region.log")
    end
  end

  def state
    self[:state] || "new"
  end

  def new_alert_notification
    AlertMailer.notify_oz(self).deliver
  end

  def create_wuoz_alert
    region = WuozRegion.where(:district_id => self.relic.district_id).first
    if region
      wuoz_alerts.find_or_create_by_wuoz_agency_id(region.wuoz_agency_id)
    else
      logger.error "#{Time.now}: alert_id(#{id}) relic_id(#{relic.id} district_id(#{relic.district_id})"
    end
    true
  end

  def formatted_body
    Haml::Engine.new(File.read("#{Rails.root}/app/views/alerts/_formatted_body.html.haml")).render(Object.new, {:alert => self})
  end
end
