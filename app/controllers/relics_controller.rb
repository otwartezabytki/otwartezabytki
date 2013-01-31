# -*- encoding : utf-8 -*-
class RelicsController < ApplicationController
  before_filter :enable_fancybox, :only => [:edit, :update]
  before_filter :no_original_version, :only => [:show]
  before_filter :uncomplete_relic_redirect,  :only => [:show, :edit, :update]

  expose(:relics) do
    tsearch.perform
  end

  expose(:relic) do
    if id = params[:relic_id] || params[:id]
      r = Relic.find(id)

      if params[:original].present? && request.get?
        r.original_relic
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

        r.attributes = (params[:relic] || {}).except(:voivodeship_id, :district_id, :commune_id) unless request.get?
        r.user_id = current_user.id if request.put? || request.post?
        r
      end
    else
      Relic.new(params[:relic])
    end
  end

  expose(:fancybox_root) do
    relic_path(relic)
  end

  helper_method :need_captcha
  before_filter :authenticate_user!, :only => [:edit, :update, :adopt, :unadopt]

  def show
    flash.now[:notice] = t(params[:notice]) if params[:notice]
    relic.present? # raise ActiveRecord::RecordNotFound before entering template
    cookies[:last_relic_id] = relic.id
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

  def administrative_level
    @voivodeship = Voivodeship.find_by_id params.get_deep('relic', 'voivodeship_id')
    @district = District.find_by_id params.get_deep('relic', 'district_id')
    @commune = Commune.find_by_id params.get_deep('relic', 'commune_id')

    @district = @commune.district if @commune
    @voivodeship = @district.voivodeship if @district

    render :partial => 'administrative_level', :layout => false
  end

  def update
    authorize! :update, relic

    if params[:section] == 'photos' && relic.license_agreement != "1"
      relic.photos.where(:user_id => current_user.id).destroy_all
      flash[:notice] = t('notices.unpublished_photos_has_been_delete')
      redirect_to relic_path(relic.id) and return
    end

    if params[:photo_id].present? && cookies[:event_avaiting_photo].present?
      relic.events_attributes = [
        {
          :id => cookies[:event_avaiting_photo].to_i,
          :photo_id => params[:photo_id]
        }
      ]
    end

    if relic.save
      if params[:entry_id]
        params[:entry_id] = nil
        render 'edit' and return
      elsif cookies[:event_avaiting_photo].present?
        if params[:photo_id].present?
          cookies.delete(:event_avaiting_photo)
          flash[:notice] = t('notices.changes_has_been_saved')
          redirect_to edit_relic_path(relic.id, :section => params[:section])
        else
          redirect_to edit_relic_path(relic.id, :section => 'attachments')
        end
      else
        if params[:section] == "photos"
          flash[:notice] = t('notices.gallery_has_been_updated')
        else
          flash[:notice] = t('notices.changes_has_been_saved')
        end

        redirect_to edit_relic_path(relic.id, :section => params[:section])
      end
    else
      flash.now[:error] = t('notices.please_correct_errors')
      render 'edit' and return
    end
  end

  def download
    append_view_path Page::Resolver.new
    file_path = Rails.root.join('public', 'history', 'current-relics.zip')

    if File.exists?(file_path)
      @export_url = '/history/current-relics.zip'
      @export_date = File.atime(file_path)
      @export_size = (File.size(file_path) / 1024.0 / 1024.0).round(2)
    end
  end

  def download_zip
    if relic.documents.count >  0

      file_name = "dokumenty-zabytku-#{relic.id}-#{relic.identification.parameterize.to_s}.zip"
      t = Tempfile.new("my-temp-filename-#{Time.now}")

      ::Zip::ZipOutputStream.open(t.path) do |zip|
        relic.documents.each do |document|
          zip.put_next_entry(document.file.identifier)
          zip.print IO.read(document.file.file.to_file)
        end
      end

      send_file t.path, :type => 'application/zip',
        :disposition => 'attachment',
        :filename => file_name

      t.close
    end
  end

  def adopt
    current_user.relics << relic

    redirect_to relic_path(relic), :notice => t('notices.relic_adopted')
  end

  def unadopt
    current_user.relics.delete(relic)

    redirect_to relic_path(relic), :notice => t('notices.relic_unadopted')
  end

  protected
    def no_original_version
      return true unless params[:original]
      current_relic = (relic || Relic.find(params[:id]))
      if current_relic.existence == 'social' or relic.blank?
        redirect_to current_relic, :notice => "Zabytek nie posiada wersji oryginalnej." and return
      end
    end

    def uncomplete_relic_redirect
      if relic and !relic.build_finished?
        relic.build_state = 'details_step'
        relic.valid?
        redirect_to method("#{relic.invalid_step_view}_relicbuilder_path").call({:id => relic}), :notice => "Twój zabytek nie jest jeszcze ukończony." and return
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
