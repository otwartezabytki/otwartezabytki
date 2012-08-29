# encoding: utf-8
class WidgetsController < ApplicationController
  layout "widget", :only => :show

  before_filter :authenticate_user!, :except => [:index, :js]

  expose(:widget_templates) { WidgetTemplate.scoped }
  expose(:widget_template)

  expose(:widgets) { current_user.widgets }
  expose(:widget) do
    the_widget = if params[:id].present?
      if params[:id].match(/^\d+$/)
        widgets.find(params[:id])
      else
        widgets.find_by_uid!(params[:id])
      end
    else
      w = widgets.build
      w.widget_template = WidgetTemplate.find(params[:widget_template_id]) if params[:widget_template_id]
      w
    end

    the_widget.attributes = params[:widget] unless request.get?
    the_widget
  end

  expose(:widget_search_results) do
    Search.new(params[:search]).perform_widget_search
  end

  def show
    if respond_to?(widget.widget_template.partial_name)
      send(widget.widget_template.partial_name)
    end
  end

  def create
    if widget.save
      redirect_to widgets_path, :notice => "Widget został stworzony"
    else
      flash[:error] = "Nie udało się stworzyć widgeta. Popraw błędy poniżej."
      render :new
    end
  end

  def update
    if widget.save
      redirect_to widgets_path, :notice => "Widget został zaktualizowany"
    else
      flash[:error] = "Nie udało się zaktualizować widgeta. Popraw błędy poniżej."
      render :edit
    end
  end

  def map_search

  end
end
