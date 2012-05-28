# -*- encoding : utf-8 -*-
class RelicsController < ApplicationController
  expose(:relics) { Relic.roots.order('id ASC').page(params[:page]) }
  expose(:relic)

  def update
    if relic.update_attributes(params[:relic])
      redirect_to relic, :notice => "Zabytek został zaktualizowany"
    else
      render :edit
    end
  end
end
