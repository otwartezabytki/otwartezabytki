class Widgets::WalkingGuidesController < WidgetsController
  layout :resolve_widget_layout, :only => [:show]

  expose(:walking_guides,  model: Widget::WalkingGuide)
  expose(:walking_guide,  model: Widget::WalkingGuide)
  expose(:widget_params) { widget.widget_params }
  expose(:widget) { walking_guides.find(params[:id]) }

  def new

  end

  def show
    respond_to do |format|
      format.html
      format.json { render :walking_guide }
    end
  end

  def create
    if walking_guide.save
      render :walking_guide
    else
      render json: { errors: walking_guide.errors }, status: :unprocessable_entity
    end
  end

  def edit

  end

  def update
    if walking_guide.save
      render :walking_guide
    else
      render json: { errors: walking_guide.errors }, status: :unprocessable_entity
    end
  end

  def print

  end

  def preview

  end

  def destroy
    walking_guide.destroy
    head :ok
  end

end
