class Widgets::WalkingGuidesController < WidgetsController
  layout :resolve_widget_layout, :only => [:show, :configure]

  expose(:widget_walking_guides, model: Widget::WalkingGuide)
  expose(:widget_walking_guide,  model: Widget::WalkingGuide)
  expose(:widget) do
    if params[:id]
      widget_walking_guides.find(params[:id])
    else
      Widget::WalkingGuide.new
    end
  end
  expose(:widget_params) { widget.widget_params }

  def new

  end

  def show

  end

  def create

  end

  def edit

  end

  def update

  end

  def print

  end

  def preview

  end

  def configure

  end

  def destroy

  end

end
