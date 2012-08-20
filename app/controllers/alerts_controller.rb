class AlertsController < ApplicationController
  before_filter :enable_fancybox

  expose(:relic) { Relic.find(params[:relic_id]) }
  expose(:alerts) { relic.alerts }
  expose(:alert)

  def create
    authorize! :create, Alert

    if alert.save
      redirect_to relic, :notice => t('notices.alert_added')
    else
      render 'new'
    end
  end
end
