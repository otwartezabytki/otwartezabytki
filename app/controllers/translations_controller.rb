# -*- encoding : utf-8 -*-
class TranslationsController < ApplicationController
  helper Tolk::ApplicationHelper
  before_filter :authenticate_admin!
  before_filter :enable_fancybox, :enable_floating_fancybox

  expose(:translation) do
    locale = Tolk::Locale.find_or_create_by_name(I18n.locale.to_s)
    phrase = Tolk::Phrase.find_or_create_by_key(params[:id])

    obj = phrase.translations.for(locale) || phrase.translations.create(:locale => locale, :text => '~')
    if params[:translation]
      obj.attributes = params[:translation]
      obj.text = YAML.load(obj.text.strip)
    end
    obj
  end

  def update
    options = (params[:options] || {}).symbolize_keys
    options[:count]   = options[:count].to_i  if options[:count]
    options[:amount]  = options[:amount].to_i if options[:amount]
    if translation.save
      @text = I18n.translate(params[:id], options)
      flash.now[:notice] ='Tłumaczenie zostało zmienione'
    else
      flash.now[:error] = 'Wystąpiły błędy podczas zapisu'
      render 'edit'
    end
  end
end
