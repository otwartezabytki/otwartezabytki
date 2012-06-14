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
end