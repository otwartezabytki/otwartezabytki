ActiveAdmin.register Relic do
  controller.authorize_resource

  filter :identification
  filter :group

  filter :voivodeship
  filter :district
  filter :commune

  index do
    column :id
    column :voivodeship
    column :district
    column :commune
    column :identification
    column :group
    column do |relic|
      if relic.versions.count > 0
        link_to "History", history_admin_relic_path(relic)
      end
    end
    default_actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :identification
      f.input :group
    end

    f.buttons
  end

  member_action :history do
    @relic = Relic.find(params[:id])
    @versions = @relic.versions
  end

  member_action :revert, :method => :put do
    @relic = Relic.find(params[:id])
    @version = @relic.versions.where(:id => params[:version]).first.reify

    if @version.save
      redirect_to admin_relic_path(@relic.id), :notice => t("notices.relic_reverted")
    else
      flash[:error] = @version.errors.full_messages
      redirect_to admin_relic_path(@relic.id, :version => @version.id)
    end
  end

  action_item :only => :show do
    link_to t('buttons.show_history'), history_admin_relic_path(resource)
  end

  action_item :only => :show  do
    unless resource.live?
      link_to t('buttons.revert_this_version'), revert_admin_relic_path(resource, :version => params[:version]),
        :method => :put, :confirm => t('messages.are_you_sure')
    end
  end

  controller do
    def show
      @relic = Relic.find(params[:id])

      if params[:version]
        @relic = @relic.versions.where(:id => params[:version]).last.reify
      end

      super
    end
  end
end
