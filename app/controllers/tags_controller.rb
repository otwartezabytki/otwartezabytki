class TagsController < ApplicationController

  respond_to :json

  expose(:tags) do
    ['foo', 'bar', 'baz']
  end

  def index
    render :json => tags.map{ |t| { id: t, text: t } }
  end

end
