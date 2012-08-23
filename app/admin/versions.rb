# encoding: utf-8

ActiveAdmin.register Version, :sort_order => 'id_desc' do
  actions :index, :show

  menu :label => "Tablica zmian", :priority => 1

  scope 'Zabytki', :relics
  scope 'Wpisy', :entries
  scope 'Wydarzenia', :events
  scope 'Linki', :links
  scope 'Zdjęcia', :photos
  scope 'Dokumenty', :documents


  index do

    column 'Data', :sortable => :created_at do |e|
      l e.created_at, :format => :short
    end

    column 'Autor' do |e|
      if e.whodunnit
        user = User.where(:id => e.whodunnit).first
        if user
          link_to user.email, admin_user_path(user.id)
        else
          "##{e.whodunnit}"
        end
      else
        "admin"
      end
    end

    column 'Akcja' do |e|
      t("version.event." + e.event)
    end

    column 'Zasób' do |e|
      object = e.reify
      name = t("version.item_type." + e.item_type)

      case e.item_type
        when "Relic"
          link_to name, admin_relic_path(e.item_id), :title => object.identification
        when "Document"
          link_to name, admin_document_path(e.item_id), :title => object.name
        when "Photo"
          link_to name, admin_photo_path(e.item_id), :title => "zabytku #{object.relic.identification}"
        when "Entry"
          link_to name, admin_entry_path(e.item_id), :title => object.title
        when "Event"
          link_to name, admin_event_path(e.item_id), :title => object.name
        when "Link"
          link_to name, admin_link_path(e.item_id), :title => object.name
      end
    end

    column 'Szybki podgląd' do |e|
      ignores = ["commune_id", "voivodeship_id", "district_id"]

      dl :style => "width: 400px;" do
        e.changeset.each do |key, (before, after)|
          next if ignores.include?(key)
          next if before.blank? && after.blank?
          dt t("activerecord.attributes.#{e.item_type.downcase}.#{key}")

          if after.class == String
            dd sanitize(HTMLDiff::DiffBuilder.new(before || "", after || "").build)
          elsif after.class == Array
            dd do
              ((after || []) - (before || [])).each do |e|
                ins e
                span " "
              end
              ((before || []) - (after || [])).each do |e|
                del e
                span " "
              end
            end
          elsif e.item_type == "Photo" && key == 'file'
            dd do
              key.class
              #image_tag before.midi.url || ""
              #image_tag after.midi.url || ""
            end
          else
            dd "#{before || "pusty"} => #{after || "~"}"
          end
        end

        "brak poważnych zmian"
      end

    end

    default_actions
  end

  show do

  end

  member_action :revert, :method => :put do
    @version = Version.find(params[:id])
    @object = @version.reify

    if @object.save
      redirect_to admin_relic_path(@relic.id), :notice => t("notices.relic_reverted")
    else
      flash[:error] = @version.errors.full_messages
      redirect_to admin_relic_path(@relic.id, :version => @version.id)
    end
  end

  filter :event, :label => "akcję", :as => :select, :collection => [["aktualizacja", "update"], ["usunięcie", "destroy"], ["utworzenie", "create"]]
end
