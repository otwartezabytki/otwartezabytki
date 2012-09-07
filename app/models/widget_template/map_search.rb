# encoding: utf-8

# == Schema Information
#
# Table name: widget_templates
#
#  id          :integer          not null, primary key
#  type        :string(255)
#  name        :string(255)
#  description :text
#  thumb       :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class WidgetTemplate::MapSearch < WidgetTemplate
  validate :width_and_height_positive

  def width_and_height_positive
    if config.width.to_i < 500
      asdfas
      errors.add(:config_width, "Musi być wieksza niż 500px")
    end

    if config.width.to_i < 500
      asdfa
      errors.add(:config_height, "Musi być wieksza niż 500px")
    end
  end

  def snippet(widget)
    if widget.id
      widget_url = Rails.application.routes.url_helpers.widget_url(widget.uid, :host => Settings.oz.host)
      "<iframe src='#{widget_url}' width='#{widget.config.width || 690}' height='#{widget.config.height || 500}'></iframe>"
    end
  end
end
