namespace :import do
  desc "Import relics from CSV. FILE=path/to/file"
  task :from_csv => :environment do
    puts "Importing ..."
    Import::Relic.parse(ENV['FILE'])
  end

  task :add_missing_places => :environment do
    Relic.where(:place_id => nil).all.map do |r|
      location = Import::CleanLocation.first(:nid_id => r.nid_id)

      p = Place.where(["LOWER(places.name) LIKE ?", Unicode.downcase(location.cit)]).first
      if p
        puts "Found! #{location.cit}"
        r.update_attributes :place => p
      else
        puts "Not Found: #{location.cit}"
        c = Commune.joins(:district => :voivodeship).where(['communes.nr = ? AND districts.nr = ? AND voivodeships.nr = ?', location.par_t, location.pov_t, location.voi_t]).first
        if c
          puts "Creating: #{location.cit}"
          p = c.places.create :name => location.cit, :from_teryt => false
          r.update_attributes :place => p
        end
      end
    end
  end

  task :clean_data => :environment do
    Import::CleanData.all.batch(1000) do |l|
      r = Relic.where(:approved => false).find_by_nid_id(l.nid_id.to_s)
      next unless r
      puts "Importing: #{l.nid_id}: #{l.okr_ob}"
      attrs = {
        :identification   => l.okr_ob,
        :street           => l.ulica.strip,
        :dating_of_obj    => l.datowanie_ob,
        :approved         => true
      }
      r.update_attributes attrs.merge(Hash[[:latitude, :longitude].zip(l.geo_norm)])
    end
  end

  task :geocode => :environment do
    Relic.roots.find_each do |r|
      logger = Logger.new("#{Rails.root}/log/#{Rails.env}_geocode_import.log")
      begin
        logger.info "relic: #{r.id}"
        geo1 = Geocoder.search(r.place_full_name).first
        geo2 = nil
        if r.street.present?
          geo2 = Geocoder.search(r.place_full_name + ", #{r.street}").first
        end
        geo = (geo2 || geo1)
        next unless geo
        r.update_attributes :latitude => geo.latitude, :longitude => geo.longitude
        logger.info "geo: #{geo.latitude}, #{geo.longitude}"
      rescue => ex
        logger.info "error: #{ex.message}"
      end
    end
  end

  task :teryt_fix_names => :environment do
    Import::Simc.fix_names
    Import::Terc.fix_names
  end

end