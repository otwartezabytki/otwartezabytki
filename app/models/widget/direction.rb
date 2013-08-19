# -*- encoding : utf-8 -*-

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

class Widget::Direction < Widget

  serialized_attr_accessor :width => 920, :height => 500
  serialized_attr_accessor :params => {}

  validates :width, :height, :presence => true,
    :numericality => { :greater_than_or_equal_to => 500, :less_than_or_equal_to => 1600 }

  def snippet
    widget_url = Rails.application.routes.url_helpers.widgets_direction_url(uid, :host => Settings.oz.host)
    "<iframe id='oz_direction' src='#{widget_url}' width='#{width}' height='#{height}'></iframe>"
  end

  def widget_params
    p = ActiveSupport::JSON.decode(params) || {} rescue {}
    waypoints_count = p.try(:[], 'waypoints').try(:count) || 0
    if waypoints_count < 2
      p['waypoints'] ||= []
      (2 - waypoints_count).times { p['waypoints'] << '' }
    end
    p
  end

end
