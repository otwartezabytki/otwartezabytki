# encoding: utf-8
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
    if Relic.index.exists?
      puts "Fast reindex of documents ..."
      new_index = "#{Time.now.to_i}_relic_reindex"
      Relic.index.reindex(new_index, :mappings => Relic.tire.mapping_to_hash, :settings => Relic.tire.settings)
      Relic.index.delete
      Tire::Index.new(new_index).add_alias(Relic.index.name)
      puts "\nDone"
    else
      print "Indexing: "
      Relic.index.delete
      Relic.index.create :mappings => Relic.tire.mapping_to_hash, :settings => Relic.tire.settings
      Relic.created.roots.includes(:place, :commune, :district, :voivodeship).find_in_batches do |objs|
        print "."
        Relic.index.import objs
      end
      puts "\nDone"
    end
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

  def export_relics(register_data = false)
    suffix = if register_data
      "relics-register"
    else
      "relics"
    end
    new_zip_path = "#{Rails.root}/public/history/#{Date.today.to_s(:db)}-#{suffix}.zip"
    if File.exists?(new_zip_path)
      puts "Nothing to do file (#{new_zip_path}) has been already generated."
    else
      puts "Exporting relics to file (#{new_zip_path})"
      total   = Relic.created.roots.count
      counter = 0
      tmpfile = Tempfile.new([suffix, '.zip'])
      begin
        Zip::ZipOutputStream.open(tmpfile.path) do |z|
          Relic.created.roots.includes(:place, :commune, :district, :voivodeship) do |objs|
            puts "Progress #{counter * 1000 * 100 / total} of 100%"
            counter += 1
            objs.each do |r|
              begin
                z.put_next_entry("#{suffix}/#{r.id}.json")
                z.print Yajl::Encoder.encode(r.to_builder(register_data).attributes!, :pretty => true, :indent => "  ")
              rescue => ex
                Raven.capture_exception(ex)
              end
            end
          end
        end
        puts "Progress 100 of 100%"
        FileUtils.cp tmpfile.path, new_zip_path
        FileUtils.chmod 'go+r', new_zip_path
        FileUtils.ln_s new_zip_path, "#{Rails.root}/public/history/current-#{suffix}.zip", :force => true
      ensure
        tmpfile.close
      end
    end
  end

  task :export => :environment do
    export_relics
    export_relics true # with revisions
  end

  task :export_users, [:export_csv] => :environment do |t, args |
sql = <<SQL
  select
    id as user_id,
    last_sign_in_ip as ip,
    email,
    username
  from
    users;
SQL
    results = ActiveRecord::Base.connection.execute(sql)
    ntuples = results.ntuples
    processed_items = 0
    CSV.open(args.export_csv, "wb", :force_quotes => true) do |csv|
      csv << results[0].keys

      results.each_entry do |entry|
        csv << entry.values
        processed_items += 1
        puts "Progress: #{processed_items}/#{ntuples}" if processed_items % 1000 == 0
      end
    end
  end

  task :export_users, [:export_csv] => :environment do |t, args |
sql = <<SQL
  select
    id as user_id,
    last_sign_in_ip as ip,
    email,
    username
  from
    users;
SQL
    results = ActiveRecord::Base.connection.execute(sql)
    ntuples = results.ntuples
    processed_items = 0
    CSV.open(args.export_csv, "wb", :force_quotes => true) do |csv|
      csv << results[0].keys

      results.each_entry do |entry|
        csv << entry.values
        processed_items += 1
        puts "Progress: #{processed_items}/#{ntuples}" if processed_items % 1000 == 0
      end
    end
  end
end
