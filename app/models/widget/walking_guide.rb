class Widget::WalkingGuide < Widget
  include WidgetsHelper

  serialized_attr_accessor :width => 920, :height => 1000
  serialized_attr_accessor :params => {}

  validates :width, :height, :presence => true,
    :numericality => { :greater_than_or_equal_to => 500, :less_than_or_equal_to => 1600 }

  def snippet
    %Q(<iframe id="oz_walking_guide" src="#{widget_url}" width="#{width}" height="#{height}"></iframe>)
  end

  def widget_url
    Rails.application.routes.url_helpers.widgets_walking_guide_url(uid, host: Settings.oz.host)
  end

  def print_path
    Rails.application.routes.url_helpers.print_widgets_walking_guide_path(uid)
  end

  def widget_params
    ActiveSupport::JSON.decode(params) || {} rescue {}
  end

  def title
    params[:title]
  end

  def description
    params[:description]
  end

  def relic_ids
    params[:relic_ids] || []
  end

  def relics
    Relic.where(id: relic_ids).map do |relic|
      relic_to_widget_data(relic, false).merge(description: relic.description)
    end.sort_by { |relic| relic_ids.index(relic[:id]) }
  end

end
