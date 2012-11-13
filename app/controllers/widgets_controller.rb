# -*- encoding : utf-8 -*-
class WidgetsController < ApplicationController
  layout :resolve_widget_layout, :only => :show

  def resolve_widget_layout
    request.xhr? ? 'ajax' : 'widget'
  end

end
