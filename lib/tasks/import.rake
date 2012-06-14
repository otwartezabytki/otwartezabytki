namespace :import do
  desc "Import relics from CSV. FILE=path/to/file"
  task :from_csv => :environment do
    puts "Importing ..."
    Import::Relic.parse(ENV['FILE'])
  end
end