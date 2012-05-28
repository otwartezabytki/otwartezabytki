# -*- encoding : utf-8 -*-
class RelicsController < ApplicationController
  expose(:relics) { Relic.roots.order('id ASC').page(params[:page]) }
  expose(:relic)
end
