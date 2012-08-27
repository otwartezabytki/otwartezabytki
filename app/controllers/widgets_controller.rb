class WidgetsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :js]

  def index
    @widgets = WidgetTemplate.all
  end

  def my
    @widgets = current_user.widgets
  end

  def new
    @template = WidgetTemplate.find(params[:template])
    @widget = @template.widgets.new
  end

  def create
    @template = WidgetTemplate.find(params[:template])
    @widget = @template.widgets.new(params[:widget])
    @widget.config = params[:config]
    @widget.user_id = current_user.id
    if @widget.save
      redirect_to @widget
    else
      render :new
    end
  end

  def show
    @widget = current_user.widgets.find(params[:id])
    @template = @widget.widget_template
  end

  def update
    @widget = current_user.widgets.find(params[:id])
    @template = @widget.widget_template

    params[:widget] ||= {}
    params[:widget][:config] = params[:config]
    if @widget.update_attributes(params[:widget])
      redirect_to @widget
    else
      render :show
    end
  end

  def js
    @widget = Widget.find_by_uid!(params[:uid])
    @config = @widget.config
    render "widgets/js/#{@widget.widget_template.partial_name}.js", :layout => false, :content_type => "application/js"
  end
end
