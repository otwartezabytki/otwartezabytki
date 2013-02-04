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

  serialized_attr_accessor :width => 920, :height => 500, :hide_sidebar => true
  serialized_attr_accessor :api_params => {}

  validates :width, :height, :presence => true, :numericality => { :greater_than_or_equal_to => 500, :less_than_or_equal_to => 1600 }
  validates :hide_sidebar, :inclusion => {:in => [true, false]}

  def snippet
    widget_url = Rails.application.routes.url_helpers.widgets_direction_url(uid, :host => Settings.oz.host)
    params = api_params.blank? || api_params.empty? ? "" : "?#{ActiveSupport::JSON.decode(api_params).to_query(:search)}" rescue ""
    "<iframe id='oz_direction' src='#{widget_url}#{params.html_safe}' width='#{width}' height='#{height}'></iframe>"
  end

end
