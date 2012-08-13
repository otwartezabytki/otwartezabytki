class PagesController < HighVoltage::PagesController
  before_filter :authenticate_user!, :only => :hello

  layout :layout_for_page

  def show
    file_path = Rails.root.join('public', 'system', 'relics_history.csv')
    if File.exists?(file_path)
      @export_url = '/system/relics_history.csv'
      @export_date = File.atime(file_path)
      @export_size = (File.size(file_path) / 1024.0 / 1024.0).round(2)
    end
    super
  end

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