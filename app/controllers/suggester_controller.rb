# -*- encoding : utf-8 -*-

class SuggesterController < ApplicationController

  def query
    results = KeywordStat.search params[:q]
    suggestions = KeywordStat.search(KeywordStat.spellcheck(params[:q])) if results.blank?

    json = []
    collection = []
    collection = results if results.present?
    collection = suggestions if suggestions.present?

    collection.each_with_index do |r, i|
      label = (results.blank? and i.zero?) ? "Czy chodziło ci o: #{r.identification}" : "#{r.identification}"
      json << {
        :label => label,
        :value => r.identification,
        :path  => relics_path(:search => {:q => r.identification})
      }
    end
    render :json => json
  end

  def place

  end

end