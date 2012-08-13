class PhotosController < ApplicationController

  before_filter :authenticate_user!, :only => [:edit, :create, :update, :destroy]

  respond_to :html, :json

  expose(:relic) { Relic.find(params[:relic_id]) }

  expose(:photos) { relic.photos }
  expose(:photo)

  expose(:tree_photos) { relic.all_photos }
  expose(:tree_photo)

  def create
    authorize! :create, photo
    photo.user = current_user
    photo.save
    redirect_to edit_section_relic_path(relic.id, :photos)
  end

  def update
    authorize! :update, photo
    photo.save
    respond_with(relic, photo)
  end

  def destroy
    authorize! :destroy, photo
    photo.destroy
    redirect_to edit_section_relic_path(relic.id, :photos)
  end

end
