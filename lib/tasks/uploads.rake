namespace :uploads do
  desc "Delete not saved [but uploaded] photos and documents from last 2 days"
  task :remove_not_saved => :environment do
  	puts "Deleting not saved uploads older than 2 days."
  	[Document, Photo].each do |klas|
  		klas.state(:uploaded).where("DATE(created_at) < '#{2.days.ago.to_date}'").each do |upload|
      	upload.destroy
      end
     puts "#{klas}s cleaned."
    end
  end
end
