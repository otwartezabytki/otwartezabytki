# -*- encoding : utf-8 -*-
class RelicsController < ApplicationController

  before_filter :enable_fancybox, :only => [:edit, :update]

  expose(:relics) do
    tsearch.perform
  end

  expose(:relic) do
    if id = params[:relic_id] || params[:id]
      r = Relic.find(id)

      if params[:original].present? && request.get? && r.versions.count > 0
        flash.now[:notice] = "To jest podgląd oryginalnej wersji zabytku. <a href='#{relic_path(id)}'>zobacz wersję obecną</a>.".html_safe
        r = r.versions.first.reify
        r.id = 0
        r
      else
        # change relic type if requested
        if params[:relic] && !request.get?
          if params[:relic]['polish_relic'] == '0' && r.class == Relic
            r.update_attribute(:type, 'ForeignRelic')
            r = Relic.find(r.id)
          elsif params[:relic]['polish_relic'] == '1' && r.class == ForeignRelic
            r.update_attribute(:type, 'Relic')
            r = Relic.find(r.id)
          end
        end

        r.attributes = params[:relic] unless request.get?
        r.user_id = current_user.id if request.put? || request.post?
        r
      end
    else
      Relic.new(params[:relic])
    end
  end

  helper_method :need_captcha
  before_filter :authenticate_user!, :only => [:edit, :create, :update]

  def show
    relic.present? # raise ActiveRecord::RecordNotFound before entering template
    if params[:section].present?
      render "relics/show/_#{params[:section]}" and return
    end
  end

  def index
    gon.highlighted_tags = relics.highlighted_tags
  end

  def edit
    relic.entries.build
  end

  def update
    authorize! :update, relic

    if params[:section] == 'photos' && relic.license_agreement != "1"
      relic.photos.where(:user_id => current_user.id).destroy_all
      flash[:notice] = "Ponieważ nie zgodziłeś się na opublikowanie dodanych zdjęć, zostały one usunięte."
      redirect_to relic_path(relic.id) and return
    end

    if relic.save
      if params[:entry_id]
        params[:entry_id] = nil
        render 'edit' and return
      else
        redirect_to relic_path(relic.id) and return
      end
    else
      flash[:error] = "Popraw proszę błędy wskazane poniżej"
      render 'edit' and return
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

    def updated_nested_resources(resource_name)
      nested_ids = []

      if params[:relic] && params[:relic]["#{resource_name}_attributes"]
        params[:relic]["#{resource_name}_attributes"].each do |index, photo|
          nested_ids.push(photo["id"].to_i) if photo["id"].to_i > 0
        end
      end

      nested_ids.size ? relic.send(resource_name.to_sym).find(nested_ids) : []
    end

  def destroyed_nested_resources(resource_name)
    nested_ids = []

    if params[:relic] && params[:relic]["#{resource_name}_attributes"]
      params[:relic]["#{resource_name}_attributes"].each do |index, photo|
        nested_ids.push(photo["id"].to_i) if photo["_destroy"].to_i != 0
      end
    end

    nested_ids.size ? relic.send(resource_name.to_sym).find(nested_ids) : []
  end

end
