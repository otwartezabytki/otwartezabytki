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
    set_user_id
    if walking_guide.save
      render :walking_guide
    else
      render json: { errors: walking_guide.errors }, status: :unprocessable_entity
    end
  end

  def edit
    authorize! :edit, walking_guide if walking_guide.user_id
  end

  def update
    authorize! :update, walking_guide if walking_guide.user_id
    set_user_id
    if walking_guide.save
      render :walking_guide
    else
      render json: { errors: walking_guide.errors }, status: :unprocessable_entity
    end
  end

  def print
    render :print, layout: 'widgets/print'
  end

  def preview

  end

  def destroy
    authorize! :destroy, walking_guide
    walking_guide.destroy
    respond_to do |format|
      format.html do
        redirect_to user_walking_guides_path(current_user.id), :notice => t('notices.walking_guide_has_been_removed')
      end
      format.json { head :ok }
    end
  end

  private

  def set_user_id
    walking_guide.user_id ||= current_user.try(:id)
  end
end
