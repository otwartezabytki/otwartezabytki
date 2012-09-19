# encoding: utf-8

class Widgets::AddRelicsController < WidgetsController

  expose(:widget_add_relics) { Widget::AddRelic.scoped }
  expose(:widget_add_relic)
  expose(:widget) { widget_add_relics.find(params[:id]) }

  def create
    if widget_add_relic.save
      redirect_to edit_widgets_add_relic_path(widget_add_relic)
    else
      flash[:error] = "Nie udało się stworzyć widgeta. Zgłoś błąd administracji."
      redirect_to widgets_path
    end
  end

  def update
    if widget_add_relic.save
      redirect_to edit_widgets_add_relic_path(widget_add_relic), :notice => "Widget został zaktualizowany"
    else
      flash[:error] = "Nie udało się zaktualizować widgeta. Popraw błędy poniżej."
      render :edit
    end
  end

end