class DownloadGenerator
  include ActiveModel::AttributeMethods

  attr_accessor :name, :file_type, :suffix, :template, :klass, :only_register

  def initialize klass, file_type, only_register
    self.klass = klass
    self.file_type = file_type
    self.name, self.suffix, self.template = prepare_name(file_type, only_register)
    self.only_register = only_register
  end

  def prepare_name file_type, only_register
    suffix, template = if only_register
      ["relics-register", "api/v1/relics/_relic_register.json.jbuilder"]
    else
      ["relics", "api/v1/relics/_relic.json.jbuilder"]
    end
    suffix = "relics-original" if self.klass.eql?(OriginalRelic)
    new_zip_path = "#{Rails.root}/public/history/#{Date.today.to_s(:db)}-#{suffix}-#{file_type}.zip"
    return new_zip_path, suffix, template
  end

  def manage_tmpfile tmpfile
    FileUtils.cp tmpfile.path, self.name
    FileUtils.chmod 0644, self.name
    FileUtils.ln_s self.name, "#{Rails.root}/public/history/current-#{self.suffix}-#{self.file_type}.zip", :force => true
  end

  def generate_zipfile
    if File.exists? self.name
      puts "Nothing to do file #{self.name} has been already generated."
    else
      puts "Exporting relics to file #{self.name}"
      total = self.klass.created.roots.count
      counter = 0
      tmpfile = Tempfile.new([self.suffix, '.zip'])
      begin
        Zip::ZipOutputStream.open(tmpfile.path) do |zip|
          @klass.created.roots.includes(:place, :commune, :district, :voivodeship).find_in_batches do |objs|
            puts "Progress #{counter * 1000 * 100 / total} of 100%"
            counter += 1
            objs.each do |relic|
              begin
                if self.file_type == "json"
                  generate_json_file(zip, relic)
                else
                  generate_csv_file(zip, relic)
                end
              rescue => ex
                Raven.capture_exception(ex)
              end
            end
          end
        end
        puts "Progress 100 of 100%"
        manage_tmpfile(tmpfile)
      ensure
        tmpfile.close
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
    zipstream.put_next_entry("#{self.suffix}-json/#{relic.id}.json")
    zipstream.print view.render(template: self.template, locals: { relic: relic, params: { include_descendants: true }})
  end

  def generate_csv_file zipstream, relic 
    zipstream.put_next_entry("#{self.suffix}-csv/#{relic.id}.csv")
    zipstream.print relic_to_csv(relic)
  end

  def relic_to_csv relic
    CSV.generate do |csv|
      csv << [I18n.t("activerecord.models.relic.one")]
      self.only_register ? original_relic_csv(relic, csv) : append_csv(csv, relic)

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
      'documents_info', 'links_info',
    ].map { |elem| I18n.t("activerecord.attributes.relic.#{elem}")}

    csv << [ relic.id, relic.nid_id, relic.identification, relic.common_name, relic.description,
      relic.categories, relic.state, relic.register_number, relic.dating_of_obj, relic.street,
      relic.latitude, relic.longitude, relic.tags, relic.country_code, relic.fprovince, relic.fplace, 
      relic.documents_info, relic.links_info, 
    ]

    unless self.only_register
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
    ].map { |elem| I18n.t("activerecord.attributes.relic.#{elem}")}

    csv << [ relic.id, relic.nid_id, relic.identification, relic.common_name, relic.description,
      relic.categories, relic.state, relic.register_number, relic.dating_of_obj, relic.street,
      relic.latitude, relic.longitude, relic.tags, 
    ]

    place_data(csv, relic)
  end

end
