class TagsController < ApplicationController
  expose(:tag)

  def create
    if tag.save
      head :ok
    else
      render :status => :bad_request, :json => { :error_message => tag.errors.full_messages }
    end
  end
end