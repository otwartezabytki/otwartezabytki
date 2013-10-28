# -*- encoding : utf-8 -*-

ActiveAdmin.register Version, :sort_order => 'id_desc' do
  actions :index, :show

  menu :label => "Tablica zmian", :priority => 1

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

    column 'Zródło' do |e|
      e.source
    end

    column 'Akcja' do |e|
      t("version.event." + e.event)
    end

    column 'Zasób' do |e|
      name = t("version.item_type." + e.item_type)
      object = e.preview
      next unless object
      case e.item_type
        when "Relic"
          link_to name, admin_relic_path(e.item_id), :title => object.identification
        when "Document"
          link_to name, admin_document_path(e.item_id), :title => object.name
        when "Photo"
          link_to name, admin_photo_path(e.item_id), :title => "zabytku #{object.relic.try(:identification)}"
        when "Entry"
          link_to name, admin_entry_path(e.item_id), :title => object.title
        when "Event"
          link_to name, admin_event_path(e.item_id), :title => object.name
        when "Link"
          link_to name, admin_link_path(e.item_id), :title => object.name
      end
    end

    column 'Szybki podgląd' do |e|
      object = e.preview
      next unless object
      ignores = ["commune_id", "voivodeship_id", "district_id"]

      dl :style => "width: 300px;" do
        if e.event == 'update'
          e.changeset.each do |key, (before, after)|
            next if ignores.include?(key)
            next if before.blank? && after.blank?
            dt t("activerecord.attributes.#{e.item_type.downcase}.#{key}")

            if after.class == String
              if key == 'file' and e.item_type == 'Document'
                dd do
                  store_dir = "/system/uploads/document/file/%d/%s"
                  span link_to("dokument", store_dir % [e.item_id, before])
                  span "=>"
                  span link_to("dokument", store_dir % [e.item_id, after])
                end
              elsif key == 'file' and e.item_type == 'Photo'
                dd do
                  store_dir = "/system/uploads/photo/file/%d/midi_%s"
                  span image_tag(store_dir % [e.item_id, before])
                  span "=>"
                  span image_tag(store_dir % [e.item_id, after])
                end
              else
                dd sanitize(HTMLDiff::DiffBuilder.new(before || "", after || "").build)
              end
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
            else
              dd "#{before || "pusty"} => #{after || "~"}"
            end
          end
        elsif e.event == 'create' || e.event == 'destroy'
          if e.item_type == "Photo"
            para do
              image_tag object.file.midi.url
            end
          elsif e.item_type == "Document"
            para do
              link_to "pobierz dokument #{object.file.identifier}", object.file.url
            end
          elsif e.item_type == "Event"
            dl do
              dt "Nazwa"
              dd object.name
              dt "Data"
              dd object.date
            end
          elsif e.item_type == "Link"
            dl do
              dt "Nazwa"
              dd object.name
              dt "URL"
              dd object.url
            end
          elsif e.item_type == "Entry"
            dl do
              dt "Tytuł"
              dd object.title
              dt "Treść"
              dd sanitize object.body
            end
          end
        end

        e.event == "update" ? "brak poważnych zmian" : ""
      end

    end

    column do |e|
      para do
        link_to("Cofnij", revert_admin_version_path(e), :method => :put, :'data-confirm' => 'Na pewno?')
      end
    end

    default_actions
  end

  member_action :revert, :method => :put do
    @version = Version.find(params[:id])
    @object = @version.reify

    if @version.event == 'create'
      Kernel.const_get(@version.item_type).find(@version.item_id).destroy
      redirect_to admin_versions_path, :notice => "Objekt został przywrócony do wersji przed zmianami."
    else
      if @object.save
        redirect_to admin_versions_path, :notice => "Objekt został przywrócony do wersji przed zmianami."
      else
        flash[:error] = @version.errors.full_messages
        redirect_to admin_version_path(@version.id)
      end
    end
  end

  action_item :only => :show  do
    link_to "Przywróć do wersji przed zmianą", revert_admin_version_path(resource), :method => :put, :'data-confirm' => 'Na pewno?'
  end

  filter :created_at, :label => "Czas zmiany"

  filter :whodunnit, :as => :string, :label => "ID użytkownika"

  filter :event, :label => "Akcja", :as => :select,
         :collection => [["aktualizacja", "update"], ["usunięcie", "destroy"], ["utworzenie", "create"]]

  filter :item_type, :label => "Rodzaj", :as => :select,
         :collection => [["Zabytek", "Relic"], ["Dokument", "Document"], ["Zdjęcie", "Photo"], ["Wpis", "Entry"], ["Wydarzenie", "Event"], ["Link", "Link"]]

  filter :item_id, :as => :numeric, :label => "ID rekordu"
end
