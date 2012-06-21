# -*- encoding : utf-8 -*-
class RelicsController < ApplicationController
  expose(:relics) { Relic.search(params) }
  expose(:relic)

  helper_method :parse_navigators, :search_params

  def update
    if relic.update_attributes(params[:relic])
      redirect_to relic, :notice => "Zabytek został zaktualizowany"
    else
      render :edit
    end
  end

  def suggester
    query = params[:q1]
    render :json => [] and return unless query.present?
    navigators = parse_navigators(Relic.suggester(query).facets, :count)
    navigators_json = []

    navigators['voivodeships'].each do |obj|
      navigators_json << {
        label: "woj. #{obj.name} (#{obj.count})",
        value: query,
        path:  relics_path(search_params.merge(:location => obj.id))
      }
    end if navigators['voivodeships'].size > 1

    navigators['districts'].each do |obj|
      navigators_json << {
        label: "pow. #{obj.name} (#{obj.count})",
        value: query,
        path:  relics_path(search_params.merge(:location => [obj.voivodeship_id, obj.id].join('-')))
      }
    end if navigators['districts'].size > 1

    navigators['communes'].each do |obj|
      navigators_json << {
        label: "gm. #{obj.name} (#{obj.count})",
        value: query,
        path:  relics_path(search_params.merge(:location => [obj.district.voivodeship_id, obj.district_id, obj.id].join('-')))
      }
    end if navigators['communes'].size > 1

    navigators['places'].each do |obj|
      navigators_json << {
        label: "#{obj.name} (#{obj.count})",
        value: query,
        path:  relics_path(search_params.merge(:location => [obj.commune.district.voivodeship_id, obj.commune.district_id, obj.commune_id, obj.id].join('-')))
      }
    end if navigators['places'].size > 1

    render :json => navigators_json
  end

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
