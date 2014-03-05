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

  desc "Generate zipfiles with relics csvs/jsons"
  task :export => :environment do
    # generating json for all relics
    DownloadGenerator.new(Relic, 'json', false).generate_zipfile
    # generating json for registered relics
    DownloadGenerator.new(Relic, 'json', true).generate_zipfile
    # generating csv for all relics
    DownloadGenerator.new(Relic, 'csv', false).generate_zipfile
    # generating csv for registered relics
    DownloadGenerator.new(Relic, 'csv', true).generate_zipfile
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

  task :auto_categories => :environment do
    puts "Updating relics categories..."
    counter = 0
    CSV.foreach "#{Rails.root}/db/csv/keywords_with_categories.csv", {col_sep: ';', headers: true} do |row|
      next if row[0].blank? or row[1].blank?
      keyword    = "%#{row[0].strip.downcase}%"
      categories = row[1].split(',').map(&:strip)
      categories.select! { |c| Category.find_by_name_key(c) }
      next if categories.blank?

      Relic.paper_trail_off

      Relic.where("LOWER(identification) LIKE ? OR LOWER(common_name) LIKE ? OR LOWER(description) LIKE ?", keyword, keyword, keyword).find_in_batches do |relics|
        relics.each do |relic|
          auto_categories = categories - relic.categories
          next if auto_categories.blank?

          relic.record_timestamps = false
          relic.categories = (relic.categories + auto_categories).uniq
          relic.auto_categories = (relic.auto_categories + auto_categories).uniq
          relic.save!
          counter += 1
        end
        puts "Progress: #{counter} relics updated"
      end
    end
    puts "Done"
  end

end
