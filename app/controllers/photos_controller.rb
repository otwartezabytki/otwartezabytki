class PhotosController < ApplicationController

  before_filter :authenticate_user!, :only => [:edit, :create, :update, :destroy]

  respond_to :html, :json

  expose(:relic) { Relic.find(params[:relic_id]) }
  expose(:photos) { relic.photos }
  expose(:photo)

  def create
    photo.user = current_user
    photo.save
    respond_with(relic, photo)
  end

  def update
    photo.save
    respond_with(relic, photo)
  end

  def destroy
    photo.destroy if photo.user == current_user
  end

end
