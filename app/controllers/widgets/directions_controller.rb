# -*- encoding : utf-8 -*-

class Widgets::DirectionsController < WidgetsController

  expose(:widget_directions) { Widget::Direction.scoped }
  expose(:widget_direction)
  expose(:widget) { widget_directions.find(params[:id]) }

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
    if widget_direction.save
      redirect_to edit_widgets_direction_path(widget_direction.id)
    else
      redirect_to widgets_path :error => t('notices.widget_error')
    end
  end

  def update
    if widget_direction.save
      redirect_to edit_widgets_direction_path(widget_direction.id), :notice => t('notices.widget_has_been_updated')
    else
      flash[:error] = t('notices.widget_error_and_correct')
      render :edit
    end
  end

end
