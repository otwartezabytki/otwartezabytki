# -*- encoding : utf-8 -*-
class AlertsController < ApplicationController
  before_filter :authenticate_user!, :only => [:new, :create]

  before_filter :enable_fancybox, :unless => lambda {|c| Subdomain.matches?(c.request) }

  expose(:relic) { Relic.find(params[:relic_id]) }
  expose(:alerts) { relic.alerts }
  expose(:alert)

  def new
    if params[:non_existent].present?
      relic.update_attributes(:existence => "archived")
      redirect_to relic_path(relic), :notice => t('notices.relic_was_archived') and return
    end
  end

  def create
    authorize! :create, Alert
    alert.user_id = current_user.try(:id)
    if alert.save
      if Subdomain.matches?(request)
        path = relic_path(relic, :host => Settings.oz.host, :only_path => false, :notice =>'notices.alert_added')
        render :js => "window.top.location = '#{path}';" and return
      end
      redirect_to relic, :notice => t('notices.alert_added')
    else
      render 'new'
    end
  end
end
