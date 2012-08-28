class AlertsController < ApplicationController
  before_filter :authenticate_user!, :only => [:new, :create]

  before_filter :enable_fancybox

  expose(:relic) { Relic.find(params[:relic_id]) }
  expose(:alerts) { relic.alerts }
  expose(:alert)

  def create
    authorize! :create, Alert

    alert.user_id = current_user.try(:id)
    if alert.save
      redirect_to relic, :notice => t('notices.alert_added')
    else
      render 'new'
    end
  end
end
