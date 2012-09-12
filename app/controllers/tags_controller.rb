class TagsController < ApplicationController

  respond_to :json

  expose(:tags) do
    Search.new(:query => params[:query]).autocomplete_tags
  end

  def index
    render :json => tags.map{ |t| { id: t, text: t } }
  end

end
