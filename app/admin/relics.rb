# -*- encoding : utf-8 -*-

ActiveAdmin.register Relic, {:sort_order => :id} do
  menu :label => "Zabytki", :parent => "Zasoby", :priority => 1

  controller.authorize_resource

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

  action_item :only => [:show, :edit] do
    link_to 'Profil zabytku', relic_path(relic), :target => "_blank"
  end

  form do |f|
    f.inputs do

      descendants = if f.object.root
        (f.object.root.descendants + [f.object.root] - [f.object]).uniq.map{ |descendant| ["#{descendant.identification} (##{descendant.id})", descendant.id]}
      else
        []
      end

      f.input :parent_id, :as => :select, :label => "ID zespołu zabytków", :collection => descendants, :selected => f.object.parent_id
      f.input :state, :as => :select, :include_blank => false, :collection => t('activerecord.attributes.relic.states').to_a.map(&:reverse)
      f.input :existence, :as => :select, :include_blank => false, :collection => t('activerecord.attributes.relic.existences').to_a.map(&:reverse)

      f.input :identification, :as => :string
      f.input :description
      f.input :place_id
      f.input :dating_of_obj
      f.input :street
      f.input :register_number, :as => :string
      f.input :nid_id
      f.input :latitude
      f.input :longitude
      f.input :approved
      f.input :categories, :as => :check_boxes,
              :collection => Category.to_hash.invert, :label => "",
              :input_html => { :multiple => true }
      f.input :tags, :input_html => { :value => relic.tags.join(','), :style => "width: 680px", :multiple => true }
      f.input :country_code
      f.input :fprovince
      f.input :fplace
      f.input :documents_info
      f.input :links_info

      f.buttons
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
