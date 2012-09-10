# encoding: utf-8

class Widgets::AddRelicsController < WidgetsController

  expose(:widgets) { Widget::AddRelic.scoped }

  def create
    if widget.save
      redirect_to edit_widgets_add_relic_path(widget.id)
    else
      flash[:error] = "Nie udało się stworzyć widgeta. Zgłoś błąd administracji."
      redirect_to widgets_path
    end
  end

  def update
    if widget.save
      redirect_to edit_widgets_add_relic_path(widget.id), :notice => "Widget został zaktualizowany"
    else
      flash[:error] = "Nie udało się zaktualizować widgeta. Popraw błędy poniżej."
      render :edit
    end
  end

end