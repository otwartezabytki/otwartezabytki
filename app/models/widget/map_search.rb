# encoding: utf-8

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

class Widget::MapSearch < Widget

  def width_and_height_positive
    if config.width.to_i < 500
      errors.add(:config_width, "Musi być wieksza niż 500px")
    end

    if config.width.to_i < 500
      errors.add(:config_height, "Musi być wieksza niż 500px")
    end
  end

  def snippet
    widget_url = Rails.application.routes.url_helpers.widgets_map_search_url(uid, :host => Settings.oz.host)
    "<iframe src='#{widget_url}' width='#{config.width || 690}' height='#{config.height || 500}'></iframe>"
  end

end
