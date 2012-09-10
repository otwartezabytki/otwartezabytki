# encoding: utf-8

class Widgets::MapSearchesController < WidgetsController

  expose(:widgets) { Widget::MapSearch.scoped }

  expose(:widget_search) do
    params[:search] ||= { :location => 'country:pl' }
    params[:search]["widget"] = "1"
    Search.new(params[:search])
  end

  expose(:relics) do
    widget_search.load = true
    widget_search.perform
  end

  def create
    if widget.save
      redirect_to edit_widgets_map_search_path(widget.id)
    else
      flash[:error] = "Nie udało się stworzyć widgeta. Zgłoś błąd administracji."
      redirect_to widgets_path
    end
  end

  def update
    if widget.save
      redirect_to edit_widgets_map_search_path(widget.id), :notice => "Widget został zaktualizowany"
    else
      flash[:error] = "Nie udało się zaktualizować widgeta. Popraw błędy poniżej."
      render :edit
    end
  end

end