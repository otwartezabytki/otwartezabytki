# clear recently modified relic on homepage
Version.instance_eval do
  after_create { Rails.cache.delete('views/recently-modified') }
end