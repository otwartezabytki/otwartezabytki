class DownloadGenerator
  include ActiveModel::AttributeMethods
  require 'spreadsheet'
  require 'stringio'


  def initialize klass, file_type, only_register
    puts "Dane wprowadzone :: #{klass} :: #{file_type} :: #{only_register}"
    @klass = klass
    @file_type = file_type
    @only_register = only_register
    prepare_name
  end

  def prepare_name
    @suffix, @template = if @only_register
                           ["relics-register", "api/v1/relics/_relic_register.json.jbuilder"]
                         else
                           ["relics", "api/v1/relics/_relic.json.jbuilder"]
                         end
    @suffix = "relics-original" if @klass.eql?(OriginalRelic)
    @name = "#{Rails.root}/public/history/#{Date.today.to_s(:db)}-#{@suffix}-#{@file_type}.zip"
  end

  def manage_tmpfile tmpfile
    FileUtils.cp tmpfile.path, @name
    FileUtils.chmod 0644, @name
    FileUtils.ln_s @name, "#{Rails.root}/public/history/current-#{@suffix}-#{@file_type}.zip", :force => true
  end

  def generate_zipfile
    if File.exists? @name
      puts "Nothing to do file #{@name} has been already generated."
    else
      if @file_type == "xls"
        csv_name = "#{Rails.root}/public/history/#{Date.today.to_s(:db)}-#{@suffix}-csv.zip"
        if File.exists? csv_name
          convert_csv_to_xls_file(csv_name)
        else
          puts "First you have to generate CSV files"
        end
      else
        puts "Exporting relics to file #{@name}"
        total = @klass.created.roots.count
        counter = 0
        tmpfile = Tempfile.new([@suffix, '.zip'])
        begin
          Zip::ZipOutputStream.open(tmpfile.path) do |zip|
            puts tmpfile.path
            iter = 0
            @klass.created.roots.includes(:place, :commune, :district, :voivodeship).find_in_batches do |objs|
              puts "Progress #{counter * 1000 * 100 / total} of 100%"
              counter += 1
              objs.each do |relic|

                iter+=1 #--------------

                begin
                  if @file_type == "json"
                    generate_json_file(zip, relic)
                  elsif @file_type == "csv"
                    generate_csv_file(zip, relic)
                  end
                rescue => ex
                  Raven.capture_exception(ex)
                end

                break if iter == 5 #-------------

              end
              break if iter == 5 #-------------
            end
            # break if iter == 5 #-------------
          end
          puts "Progress 100 of 100%"
          manage_tmpfile(tmpfile)
        ensure
          tmpfile.close
        end
      end
    end
  end

  def generate_json_file zipstream, relic
    view = ActionController::Base.new
    view.request = ActionDispatch::Request.new('rack.input' => [])
    view.response = ActionDispatch::Response.new
    view.class_eval do
      include ApplicationHelper
      include Rails.application.routes.url_helpers
    end
    zipstream.put_next_entry("#{@suffix}-json/#{relic.id}.json")
    zipstream.print view.render(template: @template, locals: {relic: relic, params: {include_descendants: true}})
  end

  def generate_csv_file zipstream, relic
    zipstream.put_next_entry("#{@suffix}-csv/#{relic.id}.csv")
    zipstream.print relic_to_csv(relic)
  end

  def relic_to_csv relic
    CSV.generate do |csv|
      csv << [I18n.t("activerecord.models.relic.one")]
      @only_register ? original_relic_csv(relic, csv) : append_csv(csv, relic)

      csv << []
      csv << [I18n.t("activerecord.models.subrelic.one").capitalize]
      relic.descendants.each do |subrelic|
        relic.class == OriginalRelic ? original_relic_csv(subrelic, csv) : append_csv(csv, subrelic)
        csv << []
      end
    end
  end

  def append_csv csv, relic
    csv << ['id', 'nid_id', 'identification', 'common_name', 'description',
            'categories', 'state', 'register_number', 'dating_of_obj', 'street',
            'latitude', 'longitude', 'tags', 'country_code', 'fprovince', 'fplace',
            'documents_info', 'links_info', 'main_photo',
    ].map { |elem| I18n.t("activerecord.attributes.relic.#{elem}") }

    csv << [relic.id, relic.nid_id, relic.identification, relic.common_name, relic.description,
            relic.categories, relic.state, relic.register_number, relic.dating_of_obj, relic.street,
            relic.latitude, relic.longitude, relic.tags, relic.country_code, relic.fprovince, relic.fplace,
            relic.documents_info, relic.links_info, relic.main_photo.try(:file_url)
    ]

    unless @only_register
      csv << []
      csv << [I18n.t("activerecord.models.event.one").capitalize]
      csv << ['id', 'date', 'name', 'photo_id'].map { |elem| I18n.t("activerecord.attributes.event.#{elem}") }
      relic.events.each do |event|
        csv << [event.id, event.date, event.name, event.photo_id]
      end
      csv << []
      csv << [I18n.t("activerecord.models.entry.one").capitalize]
      csv << ['id', 'title', 'body'].map { |elem| I18n.t("activerecord.attributes.entry.#{elem}") }
      relic.entries.each do |entry|
        csv << [entry.id, entry.title, entry.body]
      end
      csv << []
      csv << [I18n.t("activerecord.models.links.one").capitalize]
      csv << ['id', 'name', 'url', 'category', 'kind'].map { |elem| I18n.t("activerecord.attributes.link.#{elem}") }
      relic.links.each do |link|
        csv << [link.id, link.name, link.url, link.category, link.kind]
      end
      csv << []
      csv << [I18n.t("activerecord.models.document.one").capitalize]
      csv << ['id', 'name', 'description', 'url'].map { |elem| I18n.t("activerecord.attributes.document.#{elem}") }
      relic.documents.each do |document|
        csv << [document.id, document.name, document.description, document.file.try(:url)]
      end
      csv << []
      csv << [I18n.t("activerecord.models.alert.one").capitalize]
      csv << ['id', 'url', 'author', 'date_taken', 'description', 'state'].map { |elem| I18n.t("activerecord.attributes.alert.#{elem}") }
      relic.alerts.each do |alert|
        csv << [alert.id, alert.file.try(:url), alert.author, alert.date_taken, alert.description, alert.state]
      end
      csv << []
      csv << [I18n.t("activerecord.models.photo.one").capitalize]
      csv << ['id', 'url'].map { |elem| I18n.t("activerecord.attributes.photo.#{elem}") }
      relic.photos.each do |photo|
        csv << [photo.id, photo.try(:file_url)]
      end
    end

    place_data(csv, relic)
  end

  def place_data csv, relic
    if relic.place
      commune = relic.place.commune
      commune_nm = commune.name if commune
      district = commune.district if commune
      district_nm = district.name if district
      voivodeship_nm = district.voivodeship.name if district && district.voivodeship
      csv << []
      csv << [I18n.t("activerecord.models.place.one").capitalize]
      csv << ['place_id', 'commune', 'district', 'voivodeship'].map { |elem| I18n.t("activerecord.attributes.relic.#{elem}") }
      csv << [relic.place.name, commune_nm, district_nm, voivodeship_nm]
    end
  end

  def original_relic_csv relic, csv
    csv << ['id', 'nid_id', 'identification', 'common_name',
            'state', 'register_number', 'dating_of_obj', 'street',
            'latitude', 'longitude',
    ].map { |elem| I18n.t("activerecord.attributes.relic.#{elem}") }

    csv << [relic.id, relic.nid_id, relic.identification, relic.common_name, relic.description,
            relic.categories, relic.state, relic.register_number, relic.dating_of_obj, relic.street,
            relic.latitude, relic.longitude, relic.tags,
    ]

    place_data(csv, relic)
  end
  
  def convert_csv_to_xls_file csv_path
    Zip::ZipFile.foreach(csv_path) do |csv_file|
      in_stream = csv_file.get_input_stream
      data = in_stream.read
      csv = CSV.new(data)

      book = Spreadsheet::Workbook.new
      sheet1 = book.create_worksheet

      header_format = Spreadsheet::Format.new(
          :weight => :bold,
          :horizontal_align => :center,
          :bottom => :thin,
          :locked => true
      )

      sheet1.row(0).default_format = header_format
      binding.pry

        csv.each_with_index do |row, i|
          sheet1.row(i).replace(row)
        end
      file_name = csv_file.to_s.split('/').last.split('.').first
      Dir.mkdir("/tmp/#{@suffix}-xls") unless File.exists?("/tmp/#{@suffix}-xls")
      book.write("/tmp/#{@suffix}-xls/#{file_name}.xls")
    end
  end

end
