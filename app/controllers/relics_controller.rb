# -*- encoding : utf-8 -*-
class RelicsController < ApplicationController

  expose(:relics) do
    # p1 = params.merge(:corrected_relic_ids => current_user.try(:corrected_relic_ids))
    # if p1[:corrected_relic_ids].blank?
    #   Rails.cache.fetch(uniq_cache_key, :expires_in => 15.minutes) do
    #     Relic.search p1.slice(:q1, :page, :location)
    #   end
    # else
    #   Relic.search(p1)
    # end
    tsearch.perform
  end

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
    # session[:search_params] = params.slice(:q1, :location)
    gon.highlighted_tags = relics.highlighted_tags
  end

  def edit
    relic.photos.build
  end

  def update
    if relic.save
      if params[:section] == 'photos' && params[:commit].blank?
        render 'edit' and return
      else
        if relic.license_agreement != "1"
          relic.photos.where(:user_id => current_user.id).destroy_all
        end

        redirect_to relic_path(relic.id) and return
      end
    else
      flash[:error] = "Popraw proszę błędy wskazane poniżej"
      render 'edit' and return
    end
  end

  def gonext
    current_user.mark_relic_as_seen(params[:id])
    redirect_to [:edit, ensure_not_seen_relic]
  end

  def thank_you
    if current_user && current_user.suggestions.count >= 3 && current_user.email.blank?
      @request_email = true
    end

    @next_relic = ensure_not_seen_relic
  end

  def corrected
    @next_relics = Relic.next_few_for(current_user, search_params[:search_params], 3)
  end

  def suggester
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

  def download
    file_path = Rails.root.join('public', 'system', 'relics_history.csv')

    if File.exists?(file_path)
      @export_url = '/system/relics_history.csv'
      @export_date = File.atime(file_path)
      @export_size = (File.size(file_path) / 1024.0 / 1024.0).round(2)
    end
  end

  protected
    def ensure_not_seen_relic
      possible_next = Relic.next_for(current_user, session[:search_params])
      if current_user.seen_relic_ids.include?(possible_next.id.to_i)
        location = session[:search_params][:location].to_s.split('-').map {|l| l.split(':') }
        location = relic.get_parent_ids if location.blank?

        conds = Hash[
          [:voivodeship_id, :district_id, :commune_id, :place_id].zip(location)
        ].inject({}) { |mem, (k, v)| mem[k] = v if v; mem }

        next_relic = Relic.next_random_in(conds)
        next_relic = Relic.next_random_in(conds.slice(:voivodeship_id, :district_id, :commune_id)) if current_user.seen_relic_ids.include?(next_relic.id)
        next_relic = Relic.next_random_in(conds.slice(:voivodeship_id, :district_id)) if current_user.seen_relic_ids.include?(next_relic.id)
        next_relic = Relic.next_random_in(conds.slice(:voivodeship_id)) if current_user.seen_relic_ids.include?(next_relic.id)
        next_relic = Relic.next_random_in({}) if current_user.seen_relic_ids.include?(next_relic.id)
        session[:search_params] = { :q1 => nil, :location => location.map{|l| l.instance_of?(Array) ? l.join(':') : l }.join('-') }
        next_relic
      else
        possible_next
      end
    end

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

  private

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
