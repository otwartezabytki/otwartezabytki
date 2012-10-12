# -*- encoding : utf-8 -*-

# create categories
[
  {:name_key => "przemyslowy_poprzemyslowy",            :position => 1,  :column => "first"},
  {:name_key => "katolicki",                            :position => 2,  :column => "second", :group_key => "sakralny"},
  {:name_key => "prawoslawny",                          :position => 3,  :column => "second", :group_key => "sakralny"},
  {:name_key => "protestancki",                         :position => 4,  :column => "second", :group_key => "sakralny"},
  {:name_key => "zydowski",                             :position => 5,  :column => "second", :group_key => "sakralny"},
  {:name_key => "lemkowski",                            :position => 6,  :column => "second", :group_key => "sakralny"},
  {:name_key => "muzulmanski",                          :position => 7,  :column => "second", :group_key => "sakralny"},
  {:name_key => "unicki",                               :position => 8,  :column => "second", :group_key => "sakralny"},
  {:name_key => "budynek_gospodarczy",                  :position => 9,  :column => "first"},
  {:name_key => "mieszkalny",                           :position => 10, :column => "first"},
  {:name_key => "uzytecznosci_publicznej",              :position => 11, :column => "first"},
  {:name_key => "architektura_inzynieryjna",            :position => 12, :column => "first"},
  {:name_key => "mala_architektura",                    :position => 13, :column => "third"},
  {:name_key => "dworski_palacowy_zamek",               :position => 14, :column => "third"},
  {:name_key => "militarny",                            :position => 15, :column => "third"},
  {:name_key => "sportowy_kulturalny_edukacyjny",       :position => 16, :column => "third"},
  {:name_key => "park_ogrod",                           :position => 17, :column => "third"},
  {:name_key => "uklad_urbanistyczny_zespol_budowlany", :position => 18, :column => "third"}
 ].each { |hash| c = Category.find_by_name_key(hash[:name_key]); Category.create(hash) unless c }

# create static pages
Dir.glob("#{Rails.root}/db/pages/*.erb").each do |path|
  name = path.split('/').last.split('.').first
  page = Page.find_or_create_by_name(name)
  page.body = File.read(path)
  page.save
end

# create wuoz agencies
WuozAgency.connection.execute("TRUNCATE #{WuozAgency.table_name};") # truncate
hash = JSON.parse(File.open("#{Rails.root}/db/json/wuoz-agencies.json").read)
hash.each do |key, obj|
  obj['agencies'].each do |attrs|
    agency = WuozAgency.create attrs.merge('wuoz_key' => key)
    agency.district_names.split(',').map do |name|
      results = District.where(['name = ?', name.strip])
      Rails.logger.error "Cant find #{agency.id}: #{name}" if results.blank?
      results.each do |r|
        WuozRegion.find_or_create_by_wuoz_agency_id_and_district_id(agency.id, r.id)
      end
    end
  end
end
