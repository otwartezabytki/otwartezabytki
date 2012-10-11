# -*- encoding : utf-8 -*-
class LinksController < ApplicationController

  before_filter :authenticate_user!, :only => [:edit, :create, :update, :destroy]

  respond_to :html, :json

  expose(:relic) { Relic.find(params[:relic_id]) }

  expose(:links) { relic.links }
  expose(:link)

  def create
    authorize! :create, link
    link.user = current_user
    link.save
    redirect_to edit_section_relic_path(relic.id, :links)
  end

  def update
    authorize! :update, link
    link.save
    respond_with(relic, link)
  end

  def destroy
    authorize! :destroy, link
    link.destroy
    redirect_to edit_section_relic_path(relic.id, :links)
  end

end
