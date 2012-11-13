# -*- encoding : utf-8 -*-
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
    if entry.save
      redirect_to edit_section_relic_path(relic.id, :section => :entries, :entry_id => 0)
    else
      params[:section] = 'entries'
      render 'relics/edit'
    end
  end

  def destroy
    authorize! :destroy, entry
    entry.destroy
    redirect_to edit_section_relic_path(relic.id, :entries)
  end

end
