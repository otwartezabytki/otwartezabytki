# -*- encoding : utf-8 -*-
class PagesController < ApplicationController
  before_filter :authenticate_user!, :only => :hello
  layout :layout_for_page

  def show
    @page = Page.find_by_name(params[:id])
    if @page
      render :text => @page.body.html_safe, :layout => true
    else
      view = params[:id]
      render404 and return if view.blank? or !File.exists?("#{Rails.root}/app/views/pages/#{view}.html.haml")
      render view
    end
  end

  protected
    def layout_for_page
      case params[:id]
        when 'share_close' then nil
        else 'application'
      end
    end
end
