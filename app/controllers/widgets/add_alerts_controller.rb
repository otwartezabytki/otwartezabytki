# -*- encoding : utf-8 -*-

class Widgets::AddAlertsController < WidgetsController

  expose(:widget_add_alerts) { Widget::AddAlert.scoped }
  expose(:widget_add_alert)
  expose(:widget) { widget_add_alerts.find(params[:id]) }
  helper_method :searched_relics

  def create
    if widget_add_alert.save
      redirect_to edit_widgets_add_alert_path(widget_add_alert)
    else
      flash[:error] = "Nie udało się stworzyć widgeta. Zgłoś błąd administracji."
      redirect_to widgets_path
    end
  end

  def update
    if widget_add_alert.save
      redirect_to edit_widgets_add_alert_path(widget_add_alert), :notice => "Widget został zaktualizowany"
    else
      flash[:error] = "Nie udało się zaktualizować widgeta. Popraw błędy poniżej."
      render :edit
    end
  end

  protected
    def searched_relics
      @searched_relics ||= Search.new(:q => widget_add_alert.q, :load => true).perform.results
    end

end
