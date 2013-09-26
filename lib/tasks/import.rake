namespace :import do
  task :set_group_id => :environment do
    virtual_group = Commune.group("district_id, name").select("COUNT(*) AS count_all, district_id, name").all.select do |c|
      c.count_all.to_i > 1
    end
    virtual_group.each do |vg|
      commune_ids = Commune.where(:district_id => vg.district_id, :name => vg.name).order("id ASC").pluck(:id)
      virtual_ids = commune_ids.join(',')
      Commune.update_all(["virtual_id = ?", virtual_ids], :id => commune_ids)
    end
  end

  task :wuoz_agencies => :environment do
    # truncate
    ActiveRecord::Base.connection.execute(%Q{
      TRUNCATE #{WuozAgency.table_name};
      TRUNCATE #{WuozRegion.table_name};
    })
    # create wuoz agencies
    hash = JSON.parse(File.open("#{Rails.root}/db/json/wuoz-agencies.json").read)
    hash.each do |key, obj|
      voivodeship = Voivodeship.where(:name => obj['voivodeship']).first!
      obj['agencies'].each do |attrs|
        agency = WuozAgency.create attrs.merge('wuoz_key' => key)
        agency.district_names.split(',').map do |name|
          results = voivodeship.districts.where(['name = ?', name.strip])
          Rails.logger.error "Cant find #{agency.id}: #{name}" if results.blank?
          results.each do |r|
            WuozRegion.find_or_create_by_wuoz_agency_id_and_district_id(agency.id, r.id)
          end
        end
      end
    end
  end
end
