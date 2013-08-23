# -*- encoding : utf-8 -*-

ActiveAdmin.register Relic, {:sort_order => :id} do
  menu :label => "Zabytki", :parent => "Zasoby", :priority => 1

  filter :id
  filter :identification

  filter :voivodeship, :input_html => { :class => "select2", :style => "width: 241px" }, :label => "Województwo"
  filter :district, :input_html => { :class => "select2", :style => "width: 241px" }, :label => "Powiat"
  filter :commune, :input_html => { :class => "select2", :style => "width: 241px" }, :label => "Miejscowość"

  index do
    column :id
    column :identification
    column :register_number
    column :voivodeship, :sortable => false
    column :district, :sortable => false
    column :commune, :sortable => false
    default_actions
  end

   member_action :make_me_ordinary, :method => :put do
      relic = Relic.find(params[:id])
      relic.descendants.map &:destroy
      relic.update_attribute :kind, "SA"
      redirect_to({:action => :show}, :notice => "Wszystkie podzabytki zostały usunięte. Od teraz jest to zwykły zabytek.")
    end

  member_action :make_me_group, :method => :put do
    relic = Relic.find(params[:id])
    relic.update_attribute :kind, "ZE"
    redirect_to({action: :show}, notice: "Zmieniono zabytek w zespół zabytków")
  end

  action_item :only => [:show, :edit] do
    link_to 'Profil zabytku', relic_path(relic), :target => "_blank"
  end

  action_item :only => [:show, :edit] do
    link_to 'Zamień na zwykły zabytek', [:make_me_ordinary,:admin, relic], :method => 'put', :confirm => 'Uwaga, wszystkie podzabytki tego zabytku zostaną usunięte. Czy chcesz to zrobić?' if relic.is_group?
  end

  action_item :only => [:show, :edit] do
    link_to 'Zamień na zespół zabytków', [:make_me_group,:admin, relic], :method => 'put' if relic.is_root? && !relic.is_group?
  end

  form do |f|
    f.inputs do
      f.input :nid_id
      descendants = if f.object.root
        (f.object.root.descendants + [f.object.root] - [f.object]).uniq.map{ |descendant| ["#{descendant.identification} (##{descendant.id})", descendant.id]}
      else
        []
      end
      if descendants.present?
        f.input :parent_id, :as => :select, :label => "ID zespołu zabytków", :collection => descendants, :selected => f.object.parent_id
      end
      f.input :state, :as => :select, :include_blank => false, :collection => t('activerecord.attributes.relic.states').to_a.map(&:reverse)
      f.input :existence, :as => :select, :include_blank => false, :collection => t('activerecord.attributes.relic.existences').to_a.map(&:reverse)
      f.input :approved
      f.input :identification, :as => :string
      f.input :common_name
      f.input :description
      f.input :register_number, :as => :string

      f.input :dating_of_obj
      if f.object.foreign_relic?
        f.input :country_code, :as => :select, :collection => I18n.t('countries').to_a.map(&:reverse)
        f.input :fprovince
        f.input :fplace
      else
        f.input :place_id
      end
      f.input :street
      f.input :latitude
      f.input :longitude

      f.input :categories, :as => :check_boxes,
              :collection => Category.to_hash.invert, :label => false,
              :input_html => { :multiple => true }
      f.input :tags, :input_html => { :value => relic.tags.join(','), :style => "width: 680px", :multiple => true }

      f.input :documents_info,  :label => 'źródła dokumentów'
      f.input :links_info,      :label => 'źródła linków'

      f.buttons
    end
  end

  show do |relic|
    attributes_table do
      row :id
      row :reason if relic.reason?
      row :nid_id
      row :parent_id do
        relic.parent.identification
      end if relic.parent.present?
      row :approved do
        relic.reason ? 'Tak' : 'Nie'
      end
      row :state do
        relic.state_name
      end
      row :existence do
        relic.existence_name
      end
      row :identification
      row :common_name
      row :description
      row :register_number
      row :dating_of_obj
      row 'Adres' do
        relic.place_with_address
      end
      row :latitude
      row :longitude
      row :categories do
        relic.categories.map{|c| Category.to_hash[c] }.join(', ')
      end
      row :tags do
        relic.tags.join(', ')
      end
      row 'źródła dokumentów' do
        relic.documents_info
      end
      row 'źródła linków' do
        relic.links_info
      end
    end
    active_admin_comments
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
