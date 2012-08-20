# -*- encoding : utf-8 -*-

class SuggesterController < ApplicationController

  def query
    results = Search.new(params[:search]).autocomplete_name
    json = []
    results.terms('autocomplitions').each do |a|
      json << {
        :label => a['term'],
        :value => a['term']
      }
    end
    render :json => json
  end

  def place
    results = Search.new(params[:search]).autocomplete_place
    navigators_json = []

    results.terms('voivodeships', false, true).each do |hash|
      obj = hash['obj']
      navigators_json << {
        :label => "<strong>woj. #{obj.name}</strong> (#{hash['count']})",
        :value => "woj. #{obj.name}",
        :location => ['pl', obj.id].join('-')
      }
    end

    results.terms('districts', false, true).each do |hash|
      obj = hash['obj']
      navigators_json << {
        :label => "woj. #{obj.voivodeship.name}, <strong>pow. #{obj.name}</strong> (#{hash['count']})",
        :value => "woj. #{obj.voivodeship.name}, pow. #{obj.name}",
        :location => ['pl', obj.voivodeship_id, obj.id].join('-')
      }
    end

    results.terms('communes', false, true).each do |hash|
      obj = hash['obj']
      navigators_json << {
        :label => "woj. #{obj.district.voivodeship.name}, pow. #{obj.district.name}, <strong>gm. #{obj.name}</strong> (#{hash['count']})",
        :value => "woj. #{obj.district.voivodeship.name}, pow. #{obj.district.name}, gm. #{obj.name}",
        :location => ['pl', obj.district.voivodeship_id, obj.district_id, obj.id].join('-')
      }
    end

    results.terms('places', false, true).each do |hash|
      obj = hash['obj']
      navigators_json << {
        :label => "woj. #{obj.commune.district.voivodeship.name}, pow. #{obj.commune.district.name}, gm. #{obj.commune.name}, <strong>#{obj.name}</strong> (#{hash['count']})",
        :value => "woj. #{obj.commune.district.voivodeship.name}, pow. #{obj.commune.district.name}, gm. #{obj.commune.name}, #{obj.name}",
        :location => ['pl', obj.commune.district.voivodeship_id, obj.commune.district_id, obj.virtual_commune_id, obj.id].join('-')
      }
    end

    results.terms('streets', false, true).each do |hash|
      obj = hash['obj']
      street = hash['term'].split('_').first
      next if street.blank?
      navigators_json << {
        :label => "woj. #{obj.commune.district.voivodeship.name}, pow. #{obj.commune.district.name}, gm. #{obj.commune.name}, #{obj.name}, <strong> #{street}</strong> (#{hash['count']})",
        :value => "woj. #{obj.commune.district.voivodeship.name}, pow. #{obj.commune.district.name}, gm. #{obj.commune.name}, #{obj.name}, #{street}",
        :location => ['pl', obj.commune.district.voivodeship_id, obj.commune.district_id, obj.virtual_commune_id, obj.id].join('-')
      }
    end
    render :json => navigators_json.reverse
  end

end