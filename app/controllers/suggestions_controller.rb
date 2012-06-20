# -*- encoding : utf-8 -*-
class SuggestionsController < ApplicationController

  def new
    @suggestion = current_user.suggestions.new(:relic_id => params[:id])
  end

  def create
    @suggestion = current_user.suggestions.new(:relic_id => params[:id])

    if @suggestion.update_attributes(params[:suggestion])
      redirect_to thank_you_relic_path
    else
      flash[:error] = @suggestion.errors.full_messages
      render :new
    end

  end
end