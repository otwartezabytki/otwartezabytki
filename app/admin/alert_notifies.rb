# -*- encoding : utf-8 -*-

ActiveAdmin.register WuozAgency do
  menu :label => "Wysyłka", :parent => "Alerty"

  actions :index, :show
  controller.authorize_resource

  index do
    column :wuoz_name
    column :city
    column :email
    column :alerts_count
    default_actions
  end

  show do
    render 'show'
  end

  member_action :notify, :method => :post do
    if wuoz_notification.save
      redirect_to({:action => :index}, :notice => "Powiadomienie zostało wysłane")
    else
      render 'show', :layout => false
    end
  end


  filter :city

  controller do
    def scoped_collection
      WuozAgency.only_with_alerts
    end

    def wuoz_notification
      @wuoz_notification ||= resource.wuoz_notifications.new(params[:wuoz_notification])
    end
    helper_method :wuoz_notification
  end

end
