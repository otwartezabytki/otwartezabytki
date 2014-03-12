# -*- encoding : utf-8 -*-

# create categories
[
  {:name_key => "przemyslowy_poprzemyslowy",            :position => 1,  :column => "first"},
  {:name_key => "sakralny",                              :position => 2,  :column => "second",
    :children => [
      {:name_key => "katolicki",                            :position => 3,  :column => "second"},
      {:name_key => "prawoslawny",                          :position => 4,  :column => "second"},
      {:name_key => "protestancki",                         :position => 5,  :column => "second"},
      {:name_key => "zydowski",                             :position => 6,  :column => "second"},
      {:name_key => "lemkowski",                            :position => 7,  :column => "second"},
      {:name_key => "muzulmanski",                          :position => 8,  :column => "second"},
      {:name_key => "unicki",                               :position => 9,  :column => "second"},
    ]
  },

  {:name_key => "budynek_gospodarczy",                  :position => 10, :column => "first"},
  {:name_key => "mieszkalny",                           :position => 11, :column => "first"},
  {:name_key => "uzytecznosci_publicznej",              :position => 12, :column => "first"},
  {:name_key => "architektura_inzynieryjna",            :position => 13, :column => "first"},
  {:name_key => "mala_architektura",                    :position => 14, :column => "third"},
  {:name_key => "dworski_palacowy_zamek",               :position => 15, :column => "third"},
  {:name_key => "militarny",                            :position => 16, :column => "third"},
  {:name_key => "sportowy_kulturalny_edukacyjny",       :position => 17, :column => "third"},
  {:name_key => "park_ogrod",                           :position => 18, :column => "third"},
  {:name_key => "uklad_urbanistyczny_zespol_budowlany", :position => 19, :column => "third"},
  {:name_key => "cmentarny",                            :position => 20, :column => "third"}
].each do |hash|
  children = hash.delete(:children)
  parent = Category.find_by_name_key(hash[:name_key]) || Category.create(hash)
  children.each do |child_hash|
    child = Category.find_by_name_key(child_hash[:name_key]) || Category.create(child_hash)
    child.update_attributes :parent => parent
  end if children.present?
end

# create static pages
Dir.glob("#{Rails.root}/db/pages/*.erb").each do |path|
  name = path.split('/').last.split('.').first
  page = Page.find_or_create_by_name(name)
  page.body = File.read(path)
  page.save
end

Rake::Task["import:wuoz_agencies"].invoke unless Voivodeship.count.zero?
