class EventsController < ApplicationController

  before_filter :authenticate_user!, :only => [:edit, :create, :update, :destroy]

  respond_to :html, :json

  expose(:relic) { Relic.find(params[:relic_id]) }

  expose(:events) { relic.events }
  expose(:event)

  def create
    authorize! :create, event
    event.user = current_user
    event.save
    redirect_to edit_section_relic_path(relic.id, :events)
  end

  def update
    authorize! :update, event
    event.save
    respond_with(relic, event)
  end

  def destroy
    authorize! :destroy, event
    event.destroy
    redirect_to edit_section_relic_path(relic.id, :events)
  end

end
