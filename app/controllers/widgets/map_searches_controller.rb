# -*- encoding : utf-8 -*-

class Widgets::MapSearchesController < WidgetsController

  expose(:widget_map_searches, model: Widget::MapSearch)
  expose(:widget_map_search,   model: Widget::MapSearch)
  expose(:widget) { widget_map_searches.find(params[:id]) }

  expose(:widget_search) do
    params[:search] ||= { :location => 'country:pl' }
    Search.new(params[:search].merge(:widget => "1", :per_page => 100))
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
    if widget_map_search.save
      redirect_to edit_widgets_map_search_path(widget_map_search.id)
    else
      redirect_to widgets_path :error => t('notices.widget_error')
    end
  end

  def update
    if widget_map_search.save
      redirect_to edit_widgets_map_search_path(widget_map_search.id), :notice => t('notices.widget_has_been_updated')
    else
      flash[:error] = t('notices.widget_error_and_correct')
      render :edit
    end
  end

end
