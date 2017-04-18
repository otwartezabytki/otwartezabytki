# -*- encoding : utf-8 -*-
class RelicsController < ApplicationController
  before_filter :create_dupped_params, :only => [:update]
  before_filter :enable_fancybox, :only => [:edit, :update]
  before_filter :no_original_version, :only => [:show]
  before_filter :uncomplete_relic_redirect, :only => [:show, :edit, :update]

  after_filter :update_position_in_group_of_relics, only: [:update]

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
        if params[:section] == "links"
          @urls = r.all_links.select(&:url?).sort_by { |e| e.position || 1000 }
          @papers = r.all_links.select(&:paper?).sort_by { |e| e.position || 1000 }
        end

        if %w(events links).include?(params[:section]) && params[:relic] && params[:relic][section_attrs_key]
          params[:relic][section_attrs_key].delete_if { |k, v| subrelic_ids.include?(v) }
          params[:relic][section_attrs_key].each_pair { |k, v|
            v["relic_id"] = r.id
            if v["id"]
              item = Object.const_get(params[:section].singularize.capitalize).find(v["id"])
              item.update_attributes(v.except(:_destroy))
              params[:relic][section_attrs_key].delete(k) unless v[:_destroy] == "1"
            end
          }
        end

        if r.has_children? && params[:relic] != nil && request.get? == false
          @subphoto_params = {}

          if params[:relic][:photos_attributes].present?
            params[:relic][:photos_attributes].each do |photo|
                @subphoto_params[:"#{photo[0]}"] = photo[1]
                params[:relic][:photos_attributes].except!(:"#{photo[0]}")
            end
          end
        end

        r.attributes = params.fetch(:relic, {}).except(:voivodeship_id, :district_id, :commune_id) unless request.get?
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

    if params[:section] == 'categories'
      relic.auto_categories = []
    end

    if relic.save
      if subrelic_ids.present?
        errors, builds = [], []
        subrelic_ids.each { |sr|
          if sr[:id]
            subrelic_item = Object.const_get(params[:section].singularize.capitalize).find(sr[:id])
            sr[:_destroy] == "1" ? subrelic_item.destroy : subrelic_item.update_attributes(sr.except(:id, :_destroy))
          else
            subrelic = Relic.find(sr[:relic_id])
            se = params[:section] == "events" ? subrelic.events.build(sr.except(:_destroy)) : subrelic.links.build(sr.except(:_destroy))
            se.save
            if se.errors.full_messages.any?
              errors << se.errors.full_messages.join(", ")
              builds << se
            end
          end
        }
      end
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
          if errors && errors.any?
            if params[:section] == "links" && builds && builds.any?
              extra_urls = builds.select { |b| b.kind == 'url' }
              @urls = @urls + extra_urls if extra_urls && extra_urls.any?
              extra_papers = builds.select { |b| b.kind == 'paper' }
              @papers = @papers + extra_papers if extra_papers && extra_papers.any?
            end
            flash[:error] = t('notices.please_correct_errors')
            render 'edit' and return
          else
            flash[:notice] = t('notices.changes_has_been_saved')
          end
        end
        update_subrelic_photos
        redirect_to edit_relic_path(relic.id, :section => params[:section])
      end
    else
      flash.now[:error] = t('notices.please_correct_errors')
      render 'edit' and return
    end
  end

  def update_subrelic_photos
    unless @subphoto_params.blank?
      @subphoto_params.each do |photo|
        tmp_photo = Photo.find(photo[1][:id])
        tmp_photo.author = photo[1][:author]
        tmp_photo.date_taken = photo[1][:date_taken]
        tmp_photo.description = photo[1][:description]
        tmp_photo.alternate_text = photo[1][:alternate_text]
        tmp_photo.relic_id = photo[1][:relic_id]
        tmp_photo.position = photo[1][:position] unless photo[1][:position].nil?
        tmp_photo.save

      end

    end
  end

  def download_zip
    if relic.all_documents.exists?

      file_name = "dokumenty-zabytku-#{relic.id}-#{relic.identification.parameterize.to_s}.zip"
      t = Tempfile.new("my-temp-filename-#{Time.now}")

      ::Zip::ZipOutputStream.open(t.path) do |zip|
        relic.all_documents.each do |document|
          zip.put_next_entry(document.file.identifier)
          zip.print IO.read(document.file.file.to_file)
        end
      end

      send_file t.path, :type => 'application/zip',
                :disposition => 'attachment',
                :filename => file_name

      t.close
    else
      render404
    end
  end

  def adopt
    current_user.relics << relic

    redirect_to relic_path(relic), :notice => t('notices.relic_adopted')
  end

  def unadopt
    current_user.relics.delete(relic)
    path = if params[:user]
             user_path(current_user)
           else
             relic_path(relic)
           end
    redirect_to path, :notice => t('notices.relic_unadopted')
  end

  def print
    render :print, :layout => 'print'
  end

  protected

  def update_position_in_group_of_relics
    photo_attrs = @dupped_params["relic"]["photos_attributes"]
    return unless photo_attrs.present?
    photo_attrs.each do |key, val|
      Photo.find(val["id"]).update_attribute(:position_in_group_of_relics, val["position_in_group_of_relics"])
    end
  end

  def create_dupped_params
    @dupped_params = params.dup
  end

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

  def section_attrs_key
    "#{params[:section]}_attributes"
  end

  def subrelic_ids
    # TODO it won't work without memoization!!!
    return @subrelic_ids if defined?(@subrelic_ids)
    @subrelic_ids = if !request.get? && %w(events links).include?(params[:section]) && params[:relic]
                      params[:relic].fetch(section_attrs_key, {}).inject([]) do |result, (k, v)|
                        result << v if v["relic_id"].present?
                        result
                      end
                    else
                      []
                    end
  end
end
