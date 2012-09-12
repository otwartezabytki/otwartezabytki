# encoding: utf-8
class WidgetsController < ApplicationController
  layout :resolve_widget_layout, :only => :show

  before_filter :enable_fancybox, :only => [:edit, :update]

  def resolve_widget_layout
    request.xhr? ? 'ajax' : 'widget'
  end

end
