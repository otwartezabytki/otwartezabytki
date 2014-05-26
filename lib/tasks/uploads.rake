namespace :uploads do
  desc "Delete not saved [but uploaded] photos and documents from last 2 days"
  task :remove_not_saved => :environment do
    puts "Deleting not saved uploads older than 2 days."
    [Document, Photo].each do |klass|
      klass.state(:uploaded).where(
        "DATE(created_at) > ? AND DATE(created_at) < ?",
        Date.parse('15-03-2014'), 2.days.ago.to_date
      ).destroy_all
      puts "#{klass}s cleaned."
    end
  end
end
