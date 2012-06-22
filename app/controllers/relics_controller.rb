# -*- encoding : utf-8 -*-
class RelicsController < ApplicationController
  expose(:relics) { Relic.search(params) }
  expose(:suggestion) { Suggestion.new(:relic_id => params[:id]) }
  expose(:relic)

  helper_method :parse_navigators, :search_params

  before_filter :current_user!, :only => :create

  def edit
    if current_user && current_user.suggestions.where(:relic_id => params[:id]).count > 0
      redirect_to thank_you_relic_path, :notice => "Już poprawiłeś ten zabytek, dziękujemy!" and return
    end

    if relic.suggestions.count >= 3
      redirect_to thank_you_relic_path, :notice => "Ten zabytek został już przejrzany. Zapraszamy za miesiąc." and return
    end
  end

  def update

    suggestion.user_id = current_user.id

    if suggestion.update_attributes(params[:suggestion])
      redirect_to thank_you_relic_path
    else
      flash[:error] = suggestion.errors.full_messages
      render :edit
    end

  end

  def thank_you; end

  protected

  def parse_navigators(facets, order = :name)
    navigators = {}
    ['voivodeships', 'communes', 'districts', 'places'].each do |name|
      next unless facets[name]
      ids = facets[name]['terms'].map { |k| k['term']}
      klass = name.classify.constantize
      objs = klass.where(:id => ids).order('id ASC')
      sorted_counts = facets[name]['terms'].sort_by { |k| k['term'].to_i }.map { |k| k['count'] }
      objs.each_with_index do |o, i|
        o.class_eval "attr_accessor :count"
        o.count = sorted_counts[i]
      end
      navigators[name] = (order == :count ?  objs.sort_by { |k| -k.count } : objs.sort_by { |k| k.name.parameterize })
    end if relics and facets
    navigators
  end

  def search_params
    params.slice(:q1)
  end

end
