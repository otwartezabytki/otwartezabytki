# -*- encoding : utf-8 -*-
class RelicbuildersController < ApplicationController
  before_filter :enable_fancybox, :only => [:geodistance]

  def new
    @relic = Relic.new
    @location = LocationBuilder.new params[:location]
    if @location.foreign_relic?
      if geo = Geocoder.search(@location.foreign_address).first
        @relic.latitude   = geo.latitude
        @relic.longitude  = geo.longitude
      end
    elsif @location.polish_place?
      pq = PreparedQuery.new @location.polish_place
      @places = if pq.exists?
        Place.where(["LOWER(name) LIKE ?", "#{pq.clean.downcase}"]).map do |p|
          p.conditional_geocode!
          p
        end
      else
        []
      end
      @relic.place = @places.first if @places.size == 1
    end
  end

  def geodistance
    @relics = Search.new(:per_page => 20,
      :lat => params.get_deep('relic', 'latitude'),
      :lon => params.get_deep('relic', 'longitude')
    ).perform
    if @relics.total.zero?
      render :js => "window.location = '#{address_relicbuilder_path(params[:relic].slice(:latitude, :longitude, :place_id))}';"
    end
  end

  def administrative_level
    @voivodeship = Voivodeship.find_by_id params.get_deep('relic', 'voivodeship_id')
    @district = District.find_by_id params.get_deep('relic', 'district_id')
    @commune = Commune.find_by_id params.get_deep('relic', 'commune_id')

    @district = @commune.district if @commune
    @voivodeship = @district.voivodeship if @district

    render :partial => 'administrative_level', :layout => false
  end

  def address
    geo_hash = Place.find_by_position(params[:latitude], params[:longitude])
    place = if geo_hash && geo_hash.get_deep(:objs, :place)
      geo_hash.get_deep(:objs, :place)
    elsif params[:place_id].present?
      Place.find(params[:place_id])
    end
    @relic = if geo_hash && geo_hash[:foreign]
      ForeignRelic.new(
        :build_state  => 'address_step',
        :country_code => geo_hash[:country_code],
        :fprovince    => geo_hash[:voivodeship],
        :fplace       => geo_hash[:place]
      )
    else
      Relic.new :build_state => 'address_step'
    end
    @relic.place = place if place
    @relic.street = (geo_hash || {}).get_deep(:street)
  end

  def create
    attributes = (params[:relic] || {}).except(:voivodeship_id, :district_id, :commune_id)
    @relic = Relic.new attributes
    @relic = ForeignRelic.new(attributes) if @relic.foreign_relic?
    if @relic.save
      redirect_to details_relicbuilder_path(:id => @relic)
    else
      render :address
    end
  end

  def details
    @relic = Relic.find(params[:id])
    @relic.build_state = 'details_step'
  end

  def photos
    @relic = Relic.find(params[:id])
    @relic.build_state = 'photos_step'
  end

  def update
    @relic = Relic.find(params[:id])
    @relic.attributes = params[:relic]
    if @relic.build_state == 'photos_step' && @relic.license_agreement != "1"
      @relic.photos.where(:user_id => current_user.id).destroy_all
      flash[:notice] = "Ponieważ nie zgodziłeś się na opublikowanie dodanych zdjęć, zostały one usunięte."
      redirect_to photos_relicbuilder_path(:id => @relic) and return
    end
    if @relic.save
      if @relic.build_state == 'photos_step'
        @relic.update_attributes :build_state => "finish_step"
        redirect_to @relic, :notice => 'Gratulacje dodałe nowy zabytek'
      else
        redirect_to photos_relicbuilder_path(:id => @relic) and return
      end
    else
      render @relic.build_state.to_s.gsub('_step', '')
    end
  end

end
