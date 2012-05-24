# -*- encoding : utf-8 -*-
class RelicsController < ApplicationController
  expose(:relics) { Relic.page(params[:page]) }
  expose(:relic)
end
