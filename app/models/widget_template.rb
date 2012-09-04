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

class WidgetTemplate < ActiveRecord::Base
  attr_accessible :description, :type, :name, :thumb, :as => :admin

  validates :name, :presence => true

  has_many :widgets

  def partial_name
    self.class.name.underscore.split('/').last
  end

  def snippet(widget)
    widget_url = Rails.application.routes.url_helpers.widget_url(widget.uid, :host => Settings.oz.host)
    "<iframe src='#{widget_url}' width='#{widget.config.width || 635}' height='#{widget.config.height || 500}'></iframe>"
  end

  class << self
    def configuration(*args)
      args.each do |arg|
        self.class_eval <<-EOS
          def #{arg}
            config[:#{arg}]
          end

          def #{arg}=(value)
            config[:#{arg}] = value
          end
        EOS
      end
    end
  end
end
