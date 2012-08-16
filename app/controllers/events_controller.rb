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

  def sort
    params[:event].each_with_index do |event_id, index|
      event = events.all.find{ |l| l.id.to_i == event_id.to_i }
      authorize! :update, event
      event.update_attribute(:position, index + 1)
    end

    render nothing: true
  end

end
