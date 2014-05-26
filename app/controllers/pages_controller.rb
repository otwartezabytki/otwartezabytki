# -*- encoding : utf-8 -*-
class PagesController < ApplicationController
  before_filter :authenticate_user!, :only => :hello
  layout :layout_for_page
  append_view_path Page::Resolver.new

  def show
    init_download if is_download_page?(params[:id])
    render params[:id]
  end

  def init_download
    main_path = Rails.root.join('public', 'history')

    @export_files              = prepare_download(main_path.join('2*-relics-json.zip'))
    @export_csv_files          = prepare_download(main_path.join('2*-relics-csv.zip'))
    @export_files_register     = prepare_download(main_path.join('2*-relics-register-json.zip'))
    @export_csv_files_register = prepare_download(main_path.join('2*-relics-register-csv.zip'))
    @export_original_csv       = prepare_download(main_path.join('2*-relics-original-csv.zip'))
    @export_original_json      = prepare_download(main_path.join('2*-relics-original-json.zip'))
  end

  protected

  def layout_for_page
    case params[:id]
      when 'share_close' then nil
      else 'application'
    end
  end

  def prepare_download(dir_path)
    export_files = []
    Dir.glob(dir_path).sort.reverse.first(3).each do |file_path|
      file_name = File.basename(file_path)
      export_files << {
        :url => "/history/#{file_name}",
        :date => file_name[0..9],
        :size => (File.size(file_path) / 1024.0 / 1024.0).round(2) }
    end
    export_files
  end

  def is_download_page?(name)
    Page.includes(:translations).
      where("(page_translations.permalink = :name OR pages.name = :name) AND pages.name = 'download'", name: name).
      exists?
  end
end
