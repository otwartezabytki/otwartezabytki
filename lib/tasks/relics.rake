namespace :relic do
  desc "Fills the commune_id, district_id and voivodeship_id columns"
  task :cache_places => :environment do

sql = <<SQL
   update relics set
     commune_id = communes.id,
     district_id = districts.id,
     voivodeship_id = voivodeships.id
    from
      places, communes, districts, voivodeships
    where places.id = relics.place_id
      and communes.id = places.commune_id
      and districts.id = communes.district_id
      and voivodeships.id = districts.voivodeship_id;
SQL

    puts "Updating #{ Relic.count } relics..."
    ActiveRecord::Base.establish_connection
    ActiveRecord::Base.connection.execute(sql)
    puts "success"
  end

  task :reindex => :environment do
    print "Indexing: "
    Relic.index.delete
    Relic.index.create :mappings => Relic.tire.mapping_to_hash, :settings => Relic.tire.settings
    Relic.roots.find_in_batches do |objs|
      print "."
      Relic.index.import objs
    end
    puts "\nDone"
  end

  task :update_geolocation, [:import_csv] => :environment do |t, args|
    CSV.foreach(args.import_csv) do |row|
      Relic.find(row[0]).update_attributes!(:latitude => row[1], :longitude => row[2])
      puts row.join(',')
    end
  end

  task :report_centroids => :environment do
    Relic.roots.each do |relic|
      if relic.has_children?
        average_latitude = (relic.descendants.map(&:latitude).sum / relic.descendants.size).round(7)
        average_longitude = (relic.descendants.map(&:longitude).sum / relic.descendants.size).round(7)
        if average_latitude != relic.latitude
          puts relic.id.to_s + "," + average_latitude.to_s + "," + average_longitude.to_s + "," + relic.latitude.to_s + "," + relic.longitude.to_s
        end
      end
    end
  end

end
