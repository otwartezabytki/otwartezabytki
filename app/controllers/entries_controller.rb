class EntriesController < ApplicationController

  before_filter :authenticate_user!, :only => [:edit, :create, :update, :destroy]

  respond_to :html, :json

  expose(:relic) { Relic.find(params[:relic_id]) }

  expose(:entries) { relic.entries }
  expose(:entry)

  def create
    authorize! :create, entry
    entry.user = current_user
    entry.save
    redirect_to edit_section_relic_path(relic.id, :entries)
  end

  def update
    authorize! :update, entry
    entry.save
    respond_with(relic, entry)
  end

  def destroy
    authorize! :destroy, entry
    entry.destroy
    redirect_to edit_section_relic_path(relic.id, :entries)
  end

  def sort
    params[:entry].each_with_index do |entry_id, index|
      entry = entries.all.find{ |l| l.id.to_i == entry_id.to_i }
      authorize! :update, entry
      entry.update_attribute(:position, index + 1)
    end

    render nothing: true
  end

end
