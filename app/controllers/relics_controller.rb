# -*- encoding : utf-8 -*-
class RelicsController < ApplicationController

  expose(:relics) do
    tsearch.perform
  end

  expose(:suggestion) { Suggestion.new(:relic_id => params[:id]) }

  expose(:relic) do
    if id = params[:relic_id] || params[:id]
      Relic.find(id).tap do |r|
        r.attributes = params[:relic] unless request.get?
      end
    else
      Relic.new(params[:relic])
    end
  end

  helper_method :need_captcha
  before_filter :authenticate_user!, :only => [:edit, :create, :update]

  def show
    if params[:section].present?
      render "relics/show/_#{params[:section]}" and return
    end
    relic.present? # raise ActiveRecord::RecordNotFound before entering template
  end

  def index
    # SearchTerm.store(params[:q1])
    gon.highlighted_tags = relics.highlighted_tags
  end

  def update
    if params[:section]
      if relic.save
        redirect_to relic_path(relic.id, :section => params[:section]) and return
      else
        flash[:error] = "Popraw proszę błędy wskazane poniżej"
        render 'edit' and return
      end
    else
      flash[:error] = "Nie można zaktualizować całego zabytku na raz. Podaj sekcję."
      redirect_to relic_path(relic.id)
    end
  end

  def download
    file_path = Rails.root.join('public', 'system', 'relics_history.csv')

    if File.exists?(file_path)
      @export_url = '/system/relics_history.csv'
      @export_date = File.atime(file_path)
      @export_size = (File.size(file_path) / 1024.0 / 1024.0).round(2)
    end
  end

  protected
    def uniq_cache_key namespace = nil
      sliced_params = params[:q1].to_s.split.sort + params.slice(:page, :location).values
      cache_key =  (Digest::SHA1.new << sliced_params.compact.join(' ')).to_s
      if cache_key.blank?
        "blank-search-query"
      elsif namespace
        "#{namespace}-#{cache_key}"
      else
        cache_key
      end
    end

    def need_captcha
      if Rails.cache.read("need_captcha_#{request.remote_ip}")
        Rails.logger.info("Require captcha because of cache value for #{request.remote_ip}")
        return true
      end
      suggestion_count = Suggestion.roots.not_skipped.where(:ip_address => request.remote_ip).where('created_at >= ?', 1.minute.ago).count
      # puts "Suggestion count: #{suggestion_count}"
      if suggestion_count > 60
        Rails.cache.write("need_captcha_#{request.remote_ip}", 1)
        true
      else
        false
      end
    end

end
