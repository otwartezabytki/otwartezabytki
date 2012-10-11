# -*- encoding : utf-8 -*-
class PhotosController < ApplicationController

  before_filter :authenticate_user!, :only => [:edit, :create, :update, :destroy]
  before_filter :enable_fancybox, :only => [:show]

  respond_to :html, :json

  expose(:relic) { Relic.find(params[:relic_id]) }

  expose(:photos) { relic.photos }
  expose(:photo)

  expose(:tree_photos) { relic.all_photos }
  expose(:tree_photo)

  def create
    authorize! :create, photo
    photo.user = current_user
    if photo.save
      choosen_redirect_path
    else
      flash[:error] = photo.errors.first.last
      redirect_to edit_section_relic_path(relic.id, :photos)
    end
  end

  def update
    authorize! :update, photo
    photo.save
    respond_with(relic, photo)
  end

  def destroy
    authorize! :destroy, photo
    photo.destroy
    choosen_redirect_path
  end

  private
    def choosen_redirect_path
      path = if !!params[:build]
        photos_relicbuilder_path(:id => relic.id)
      else
        edit_section_relic_path(relic.id, :photos)
      end
      redirect_to path
    end

end
