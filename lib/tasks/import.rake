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

end