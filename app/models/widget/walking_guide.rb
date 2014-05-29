class Widget::WalkingGuide < Widget

  serialized_attr_accessor :width => 920, :height => 1000
  serialized_attr_accessor :params => {}

  validates :width, :height, :presence => true,
    :numericality => { :greater_than_or_equal_to => 500, :less_than_or_equal_to => 1600 }

  def snippet
    widget_url = Rails.application.routes.url_helpers.widgets_walking_guides_url(uid, :host => Settings.oz.host)
    "<iframe id='oz_walking_guide' src='#{widget_url}' width='#{width}' height='#{height}'></iframe>"
  end

  def widget_params
    ActiveSupport::JSON.decode(params) || {} rescue {}
  end

end
