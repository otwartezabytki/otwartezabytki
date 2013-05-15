# -*- encoding : utf-8 -*-

ActiveAdmin.register Page do
  menu :label => "Strony statyczne"
  actions :index, :edit, :update, :new, :create, :destroy

  index do
    column :name
    column :title
    column :permalink
    column :parent_id do |page|
      page.parent ? page.parent.name : "-"
    end
    default_actions
  end

  form do |f|
    if resource.errors[:permalink].any?
      resource.errors[:permalink].each do |error|
        f.form_buffers.last << f.template.content_tag(:p, "Permalink: #{error}", class: 'errors')
      end
    end
    if resource.errors[:title].any?
      resource.errors[:title].each do |error|
        f.form_buffers.last << f.template.content_tag(:p, "Title: #{error}", class: 'errors')
      end
    end
    f.inputs do
      f.input :name
      f.input :parent_id, :as => :select, :label => "Strona należy do", :collection => Page.roots, :selected => f.object.parent_id
    end
    f.globalize_inputs :translations do |lf|
      lf.inputs do
        lf.input :title
        lf.input :permalink
        lf.input :body
        lf.input :locale, :as => :hidden
      end
    end
    f.buttons
  end

  show do |page|
    attributes_table do
      row :id
      row :name
      row :parent_id do
        page.parent.identification
      end if page.parent.present?
    end
  end

  filter :name
end
