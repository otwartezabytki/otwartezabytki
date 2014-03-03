# -*- encoding : utf-8 -*-

class Widgets::AddAlertsController < WidgetsController

  expose(:widget_add_alerts, model: Widget::AddAlert)
  expose(:widget_add_alert,  model: Widget::AddAlert)

  expose(:widget) do
    if params[:id].present?
      widget_add_alerts.find(params[:id])
    else
      Widget::AddAlert.new(:relic_id => params[:relic_id])
    end
  end

  helper_method :searched_relics

  def create
    if widget_add_alert.save
      redirect_to edit_widgets_add_alert_path(widget_add_alert)
    else
      redirect_to widgets_path :error => t('notices.widget_error')
    end
  end

  def update
    if widget.relic_id != widget_add_alert.relic_id and widget_add_alert.save
      redirect_to edit_widgets_add_alert_path(widget_add_alert), :notice => t('notices.widget_has_been_updated')
    else
      render :edit
    end
  end

  protected
    def searched_relics
      @searched_relics ||= Search.new(:q => widget_add_alert.q, :load => true).perform.results if widget_add_alert.q.present?
    end

end
