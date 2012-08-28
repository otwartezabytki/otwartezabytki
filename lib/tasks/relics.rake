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
    print "Indexing: "
    Relic.index.delete
    Relic.index.create :mappings => Relic.tire.mapping_to_hash, :settings => Relic.tire.settings
    Relic.roots.includes(:place, :commune, :district, :voivodeship, :suggestions).find_in_batches do |objs|
      print "."
      Relic.index.import objs
    end
    puts "\nDone"
  end

  task :fix_counters => :environment do
    Suggestion.find_each do |s|
      s.update_attribute :skipped, s.is_skipped?
    end
    Relic.update_all(:skip_count => 0, :edit_count => 0)
    Suggestion.where(:ancestry => nil).find_each { |s| s.update_relic_skip_cache }
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

  task :export_init, [:export_csv] => :environment do |t, args|


sql = <<SQL
  select
    'rel_' || r.id as export_id,
    timestamp with time zone '2012-06-01 00:00:00+02' at time zone 'CETDST' as suggested_at,
    r.id as relic_id,
    r.nid_id as nid_id,
    r.kind as nid_kind,
    r.ancestry as relic_ancestry,
    r.register_number as register_number,
    v.name as voivodeship,
    d.name as district,
    c.name as commune,
    p.name as place,
    r.place_id as place_id,
    'revision' as place_id_action,
    r.identification as identification,
    'revision' as identification_action,
    r.street as street,
    'revision' as street_action,
    r.dating_of_obj as dating,
    'revision' as dating_action,
    r.latitude as latitude,
    r.longitude as longitude,
    'revision' as coordinates_action,
    regexp_replace(trim(E'\n ' from regexp_replace(substring(r.tags from 7), E'[^A-Za-zżółćęśąźńŻÓŁĆĘŚĄ\\s\\n_]', '', 'g')), E'\\n\\s*', ',', 'g') as categories,
    'revision' as categories_action,
    'none' as user_id
  from
    relics as r,
    places as p,
    communes as c,
    districts as d,
    voivodeships as v
  where p.id = r.place_id
  and c.id = r.commune_id
  and d.id = r.district_id
  and v.id = r.voivodeship_id;
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

  task :export, [:export_csv, :limit] => :environment do |t, args|

sql = <<SQL
  select
    'sug_' || s.id as export_id,
    date_trunc('seconds', s.created_at AT TIME ZONE 'GMT') AT TIME ZONE 'CETDST' as suggested_at,
    r.id as relic_id,
    r.nid_id as nid_id,
    r.kind as nid_kind,
    r.ancestry as relic_ancestry,
    r.register_number as register_number,
    v.name as voivodeship,
    d.name as district,
    c.name as commune,
    p.name as place,
    s.place_id as place_id,
    s.place_id_action as place_id_action,
    s.identification as identification,
    s.identification_action as identification_action,
    s.street as street,
    s.street_action as street_action,
    s.dating_of_obj as dating,
    s.dating_of_obj_action as dating_action,
    s.latitude as latitude,
    s.longitude as longitude,
    s.coordinates_action as coordinates_action,
    regexp_replace(trim(E'\n ' from regexp_replace(substring(s.tags from 7), E'[^A-Za-zżółćęśąźńŻÓŁĆĘŚĄ\\s\\n_]', '', 'g')), E'\\n\\s*', ',', 'g') as categories,
    s.tags_action as categories_action,
    s.user_id
  from
    suggestions as s,
    relics as r,
    places as p,
    communes as c,
    districts as d,
    voivodeships as v
  where s.relic_id = r.id
  and p.id = s.place_id
  and c.id = r.commune_id
  and d.id = r.district_id
  and v.id = r.voivodeship_id
SQL

    abort "You need to run :export_init task first and create export file." unless File.exist?(args.export_csv)

    last_name, last_id = `tail -n 1 #{args.export_csv}`.split(',').first.match(/(\w+)_(\d+)/).captures

    if last_name == 'sug'
      puts "Limiting query to ids greather than #{last_id}"
      sql += " and s.id > #{last_id}"
    end

    sql += ' order by s.id asc'

    if args.limit
      puts "Limiting query to #{args.limit} records"
      sql += " limit #{args.limit}"
    end

    results = ActiveRecord::Base.connection.execute(sql)

    ntuples = results.ntuples
    puts "Processing #{ntuples} tuples"

    processed_items = 0
    CSV.open(args.export_csv, "ab", :force_quotes => true) do |csv|
      results.each_entry do |entry|
        csv << entry.values
        processed_items += 1
        puts "Progress: #{processed_items}/#{ntuples}" if processed_items % 1000 == 0
      end
    end

  end

end
