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
end