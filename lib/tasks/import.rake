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
end