# -*- encoding : utf-8 -*-
class AdministrativeDivisionsController < ApplicationController

  respond_to :html, :json

  def index
    # top down
    @voivodeship = Voivodeship.find_by_id(params[:voivodeship_id])
    @district    = District.find_by_id(params[:district_id])
    @commune     = Commune.find_by_id(params[:commune_id].to_s.split(','))
    @place       = Place.find_by_id(params[:place_id])

    # bottom up
    @commune     = @place.commune        if @place
    @district    = @commune.district     if @commune
    @voivodeship = @district.voivodeship if @district

    @voivodeships = Voivodeship.order('name')
    @districts    = @voivodeship ? @voivodeship.districts.order('name') : []
    @communes     = @district    ? @district.communes.order('name')     : []
    @places       = @commune     ? @commune.places.order('name')        : []
  end
end
