# -*- encoding : utf-8 -*-

class Widgets::TimelinesController < WidgetsController

  expose(:widget_timelines) { Widget::Timeline.scoped }
  expose(:widget_timeline)
  expose(:widget) { widget_timelines.find(params[:id]) }

  expose(:widget_search) do
    params[:search] ||= { :location => 'country:pl' }
    Search.new(params[:search].merge(:widget => "1"))
  end

  expose(:relics) do
    widget_search.load = true
    widget_search.perform
  end

  def show
    widget_search
    relics
  end

  def create
    if widget_timeline.save
      redirect_to edit_widgets_timeline_path(widget_timeline.id)
    else
      redirect_to widgets_path :error => t('notices.widget_error')
    end
  end

  def update
    if widget_timeline.save
      redirect_to edit_widgets_timeline_path(widget_timeline.id), :notice => t('notices.widget_has_been_updated')
    else
      flash[:error] = t('notices.widget_error_and_correct')
      render :edit
    end
  end

end
