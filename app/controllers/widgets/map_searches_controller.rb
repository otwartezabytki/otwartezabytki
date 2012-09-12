# encoding: utf-8

class Widgets::MapSearchesController < WidgetsController

  expose(:widget_map_searches) { Widget::MapSearch.scoped }
  expose(:widget_map_search)
  expose(:widget) { widget_map_searches.find(params[:id]) }

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
    if widget_map_search.save
      redirect_to edit_widgets_map_search_path(widget_map_search.id)
    else
      flash[:error] = "Nie udało się stworzyć widgeta. Zgłoś błąd administracji."
      redirect_to widgets_path
    end
  end

  def update
    if widget_map_search.save
      redirect_to edit_widgets_map_search_path(widget_map_search.id), :notice => "Widget został zaktualizowany"
    else
      flash[:error] = "Nie udało się zaktualizować widgeta. Popraw błędy poniżej."
      render :edit
    end
  end

end