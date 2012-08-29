# == Schema Information
#
# Table name: widgets
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  widget_template_id :integer
#  uid                :string(255)
#  config             :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Widget < ActiveRecord::Base
  attr_accessible :config, :as => [:default, :admin]

  belongs_to :user
  belongs_to :widget_template

  serialize :config, Hash

  def config
    OpenStruct.new(self.attributes['config'])
  end

  validates :widget_template_id, :presence => true

  def snippet(host)
    widget_url = Rails.application.routes.url_helpers.widget_url(uid, :host => host)
    "<iframe src='#{widget_url}' width='#{config.width || 635}' height='#{config.height || 500}'></iframe>"
  end


  protected

  before_create :generate_uid

  def generate_uid
    self.uid ||= Devise.friendly_token
  end
end
