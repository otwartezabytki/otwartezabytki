# -*- encoding : utf-8 -*-

class Widgets::AddRelicsController < WidgetsController

  expose(:widget_add_relics) { Widget::AddRelic.scoped }
  expose(:widget_add_relic)
  expose(:widget) { widget_add_relics.find(params[:id]) }

  def create
    if widget_add_relic.save
      redirect_to edit_widgets_add_relic_path(widget_add_relic)
    else
      edirect_to widgets_path :error => t('notices.widget_error')
    end
  end

  def update
    if widget_add_relic.save
      redirect_to edit_widgets_add_relic_path(widget_add_relic), :notice => t('notices.widget_has_been_updated')
    else
      flash[:error] = t('notices.widget_error_and_correct')
      render :edit
    end
  end

end
