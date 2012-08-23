# -*- encoding : utf-8 -*-
class Relics::BuildController < ApplicationController
  include Wicked::Wizard
  before_filter :enable_fancybox, :only => [:area]
  before_filter :slice_params

  steps :address, :details, :photos
  expose(:relic)

  def area
    @relics = Search.new(:per_page => 20,
      :lat => params.get_deep('relic', 'latitude'),
      :lon => params.get_deep('relic', 'longitude')
    ).perform
  end

  def show
    render_wizard
  end

  def update
    if step.to_s == 'photos' && relic.license_agreement != "1"
      relic.photos.where(:user_id => current_user.id).destroy_all
      flash[:notice] = "Ponieważ nie zgodziłeś się na opublikowanie dodanych zdjęć, zostały one usunięte."
      redirect_to relic_build_path(relic, :photos) and return
    end
    relic.update_attributes :build_state => "#{step.to_s}_step"
    render_wizard relic
  end

  private
    def redirect_to_finish_wizard(options = nil)
      relic.update_attributes :build_state => "finish_step"
      redirect_to relic, :notice => 'Gratulacje'
    end

    def slice_params
      params[:relic] = (params[:relic] || {}).except(:voivodeship_id, :district_id, :commune_id)
    end
end
