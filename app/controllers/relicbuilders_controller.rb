# -*- encoding : utf-8 -*-
class RelicbuildersController < ApplicationController
  before_filter :enable_fancybox, :only => [:geodistance]

  def new
    @relic = Relic.new
    if params[:q].present?
      pq = PreparedQuery.new(params[:q])
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
  end

  def address
    @relic = Relic.new :build_state => 'address_step'
    geo_hash = Place.find_by_position(params[:latitude], params[:longitude])
    place = if geo_hash && geo_hash.get_deep(:objs, :place)
      geo_hash.get_deep(:objs, :place)
    elsif params[:place_id]
      Place.find(params[:place_id])
    end

    @relic.place = place if place
    @relic.street = (geo_hash || {}).get_deep(:street)
  end

  def create
    @relic = Relic.new (params[:relic] || {}).except(:voivodeship_id, :district_id, :commune_id)
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
