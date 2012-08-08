class PagesController < HighVoltage::PagesController
  before_filter :authenticate_user!, :only => :hello

  layout :layout_for_page

  protected
  def layout_for_page
    case params[:id]
      when 'share_close'
        nil
      when 'under_construction'
        'under_construction'
      else
        'application'
    end
  end
end