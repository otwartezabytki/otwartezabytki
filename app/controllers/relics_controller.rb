# -*- encoding : utf-8 -*-
class RelicsController < ApplicationController
  expose(:relics) { Relic.search(params) }
  expose(:relic)
  helper_method :navigators

  def update
    if relic.update_attributes(params[:relic])
      redirect_to relic, :notice => "Zabytek został zaktualizowany"
    else
      render :edit
    end
  end

  def navigators
    navigators = {}
    ['voivodeships', 'communes', 'districts', 'places'].each do |name|
      next unless relics.facets[name]
      ids = relics.facets[name]['terms'].map { |k| k['term']}
      klass = name.classify.constantize
      objs = klass.where(:id => ids).order('id ASC')
      sorted_counts = relics.facets[name]['terms'].sort_by { |k| k['term'].to_i }.map { |k| k['count'] }
      objs.each_with_index do |o, i|
        o.class_eval "attr_accessor :count"
        o.count = sorted_counts[i]
      end
      navigators[name] = objs.sort_by { |k| k.name.parameterize }
    end if relics and relics.facets
    navigators
  end

end
