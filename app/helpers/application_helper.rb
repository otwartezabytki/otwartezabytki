# -*- encoding : utf-8 -*-
module ApplicationHelper

  def location_array
    return @location_array if defined? @location_array
    @location_array = (search_params[:search][:location] || 'pl').to_s.split('-')
  end

  def link_to_browse(obj, deep, &block)
    name, id  = extract_name(obj['term'])
    label     = "#{name} <span>#{obj['count']}</span>".html_safe
    cond      = {:search => {:location => (location_array.first(deep) << id).join('-')}}
    link      = link_to label, relics_path(cond)
    output = []
    output << link
    if block_given?
      output.join.html_safe + capture(&block)
    else
      output.join.html_safe
    end
  end

  def link_to_facet(obj, deep, &block)
    name, id  = extract_name(obj['term'])
    selected  = location_array[deep] == id
    label     = "#{name} <span>#{obj['count']}</span>".html_safe
    cond      = search_params({:location => (location_array.first(deep) << id).join('-')})
    link      = link_to label, relics_path(cond), :remote => true
    output = []
    if selected
      output << content_tag(:div, :class => 'selected') do
        if location_array.size == (deep + 1)
          content_tag(:p, label)
        else
          link
        end
      end
    else
      output <<  link
    end
    if selected and block_given?
      output.join.html_safe + capture(&block)
    else
      output.join.html_safe
    end
  end

  def extract_name(term)
    if term.include?('_')
      splt = term.split('_')
      id   = splt.pop
      [splt.join('_'), id]
    else
      [I18n.t(term.upcase, :scope => 'countries'), term]
    end
  end

  def enabled_locales_collection
    enabled_locales.map { |l| [I18n.t("common.lang.#{l}"), l.to_s] }
  end

  def t(key, options = {})
    options.symbolize_keys!
    options.reverse_merge(editable: true)
    value = I18n.translate(scope_key_by_partial(key), options)
    if options[:editable] && current_user.try(:admin?) && value.is_a?(String)
      content_tag(:i18n, value, {:'data-key' => key, :'data-options' => {:options => options, :locale => I18n.locale}.to_param}, false)
    else
      value.respond_to?(:html_safe) ? value.html_safe : value
    end
  end

  def page_path(page_or_permalink)
    id = page_or_permalink.is_a?(Page) ? page_or_permalink.permalink : page_or_permalink
    eval("#{I18n.locale.to_s.underscore}_page_path('#{h id}')")
  end

  def set_relic_img_alt(relic)
    if relic.has_photos?
      "#{relic.identification} #{relic.main_photo.alternate_text}"
    else
      "#{I18n.t('activerecord.attributes.relic.photos_facets.F')}"
    end
  end

  def set_img_alt(relic, photo)
    if relic.has_photos?
      "#{relic.identification} #{photo.alternate_text}"
    else
      "#{I18n.t('activerecord.attributes.relic.photos_facets.F')}"
    end
  end
end
