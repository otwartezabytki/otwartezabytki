namespace :places do
  desc "Fills the commune_id, district_id and voivodeship_id columns"
  task :remove_duplicates => :environment do
    data = File.read(Rails.root.join('db/simc_duplicates.csv')).split("\n").map { |n| n.split('|') }

    places = Place.where(sym: data.map { |d| d[1] })

    to_process = places.map do |place|
      [place, Place.where(sym: data.find { |d| d[1] == place.sym }[2]).first ] 
    end

    to_process.each do |(place, new_place)|
      place.relics.each do |relic|
        puts "Change relics #{relic.id} place from #{relic.place_id} (#{relic.place.name}) to #{new_place.id} (#{new_place.name})"
        relic.update_attributes(:place_id => new_place.id)
      end
    
      puts "Removing place #{place.id}..."
      place.delete
    end
  end
end
