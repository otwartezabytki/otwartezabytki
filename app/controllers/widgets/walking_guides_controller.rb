class Widgets::WalkingGuidesController < WidgetsController
  layout :resolve_widget_layout, :only => [:show, :configure]

  expose(:walking_guide,  model: Widget::WalkingGuide)
  expose(:widget_params) { widget.widget_params }

  def new

  end

  def show
      render :walking_guide
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

  def configure

  end

  def destroy
    walking_guide.destroy
    head :ok
  end

end
