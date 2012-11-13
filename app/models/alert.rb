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

  attr_accessible :relic_id, :user_id, :file, :description
  attr_accessible :state, :as => :admin

  after_create :new_alert_notification
  after_create :create_wuoz_alerts
  after_destroy :destroy_wuoz_alerts

  validates :description, :presence => true

  scope :fixed, where("state = ?", "fixed")
  scope :not_fixed, where("state != ? or state is null", "fixed")

  mount_uploader :file, AlertUploader

  def state
    self[:state] || "new"
  end

  def new_alert_notification
    AlertMailer.notify_oz(self).deliver
  end

  def create_wuoz_alerts
    WuozRegion.where(:district_id => self.relic.district_id).all.each do |region|
      WuozAlert.find_or_create_by_wuoz_agency_id_and_alert_id(region.wuoz_agency_id, self.id)
    end
    true
  end

  def destroy_wuoz_alerts
    WuozRegion.where(:district_id => self.relic.district_id).all.each do |region|
      WuozAlert.where(:wuoz_agency_id => region.wuoz_agency_id, :alert_id => self.id).destroy_all
    end
    true
  end

  def formatted_body
    Haml::Engine.new(File.read("#{Rails.root}/app/views/alerts/_formatted_body.html.haml")).render(Object.new, {:alert => self})
  end
end
