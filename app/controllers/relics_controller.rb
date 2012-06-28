# -*- encoding : utf-8 -*-
class RelicsController < ApplicationController
  expose(:relics) { Relic.search(params) }
  expose(:suggestion) { Suggestion.new(:relic_id => params[:id]) }
  expose(:relic)

  helper_method :parse_navigators, :search_params, :location_breadcrumbs

  before_filter :current_user!, :only => [:edit, :create, :update, :suggest_next, :thank_you]

  def index
    gon.highlighted_tags = relics.highlighted_tags
  end

  def edit
    if current_user && current_user.suggestions.where(:relic_id => params[:id]).count > 0
      redirect_to thank_you_relics_path, :notice => "Już poprawiłeś ten zabytek, dziękujemy!" and return
    end

    if relic.suggestions.count >= 3
      redirect_to thank_you_relics_path, :notice => "Ten zabytek został już przejrzany. Zapraszamy za miesiąc." and return
    end

    suggestion.fill_subrelics
  end

  def update

    suggestion.user_id = current_user.id

    if suggestion.update_attributes(params[:suggestion])
      redirect_to thank_you_relics_path
    else
      flash[:error] = suggestion.errors.full_messages
      render "edit"
    end

  end

  def thank_you
    if current_user && current_user.suggestions.count >= 3 && current_user.email.blank?
      @request_email = true
    end
  end


  def suggester
    query = params[:q1].to_s.strip
    render :json => [] and return unless query.present?
    results = Relic.suggester(query)
    navigators = parse_navigators(results.facets, :count)
    navigators_json = []

    navigators_json << {
      :label => "cała Polska (#{results.total_count})",
      :value => query,
      :path  => relics_path(search_params)
    } unless results.total_count.zero?

    navigators['voivodeships'].each do |obj|
      navigators_json << {
        :label => "<strong>#{query}</strong> - woj. #{obj.name} (#{obj.count})",
        :value => query,
        :path  => relics_path(search_params.merge(:location => obj.id))
      }
    end if navigators['districts'].size > 1

    navigators['districts'].each do |obj|
      navigators_json << {
        :label => "<strong>#{query}</strong> - pow. #{obj.name}, woj. #{obj.voivodeship.name} (#{obj.count})",
        :value => query,
        :path  => relics_path(search_params.merge(:location => [obj.voivodeship_id, obj.id].join('-')))
      }
    end if navigators['communes'].size > 1

    navigators['communes'].each do |obj|
      navigators_json << {
        :label => "<strong>#{query}</strong> - gm. #{obj.name}, pow. #{obj.district.name}, woj. #{obj.district.voivodeship.name} (#{obj.count})",
        :value => query,
        :path  => relics_path(search_params.merge(:location => [obj.district.voivodeship_id, obj.district_id, obj.id].join('-')))
      }
    end if navigators['places'].size > 1

    navigators['places'].each do |obj|
      navigators_json << {
        :label => "<strong>#{query}</strong> - #{obj.name}, gm. #{obj.commune.name}, pow. #{obj.commune.district.name}, woj. #{obj.commune.district.voivodeship.name} (#{obj.count})",
        :value => query,
        :path  => relics_path(search_params.merge(:location => [obj.commune.district.voivodeship_id, obj.commune.district_id, obj.commune_id, obj.id].join('-')))
      }
    end

    render :json => navigators_json
  end

  protected

    def parse_navigators(facets, order = :name)
      navigators = {}
      ['voivodeships', 'districts', 'communes', 'places'].each do |name|
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

    def location_breadcrumbs
      return @location_breadcrumbs if defined? @location_breadcrumbs
      @location_breadcrumbs = [ ]
      klasses = [Voivodeship, District, Commune, Place]
      location_arry = params[:location].to_s.split('-')

      location_arry.each_with_index do |id,i|
        l = klasses[i].find(id)
        @location_breadcrumbs << {:path => relics_path(search_params.merge(:location =>location_arry.first(i+1).join('-'))), :label => l.name }
      end if location_arry.present?
      @location_breadcrumbs
    end


end
