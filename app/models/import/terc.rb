# -*- encoding : utf-8 -*-
module Import
  # terc --> GUSowska baza terytu (województwo, powiat, gmina)
  class Terc
    include DataMapper::Resource
    storage_names[:default] = 'terc'

    property :woj, String, :key => true
    property :pow, String, :key => true, :required => false
    property :gmi, String, :key => true, :required =>false
    property :rodz, String
    property :nazwa, String, :key => true
    property :nazdod, String, :key => true
    property :stan_na, String

    class << self
      def import_all!
        import_voivodeships
        import_districts
        import_communes
        nil
      end

      def import_voivodeships
         Terc.all(:conditions => {:nazdod => 'województwo'}).batch(1000) do |t|
          Voivodeship.find_or_create_by_nr_and_name(t.woj, Unicode.capitalize(t.nazwa))
        end
      end

      def import_districts
        Terc.all(:conditions => {:pow.not => nil, :gmi => nil}).batch(1000) do |t|
          v = Voivodeship.find_by_nr!(t.woj)
          conds = {:nr => t.pow, :name => Unicode.capitalize(t.nazwa)}
          v.districts.where(conds).first || v.districts.create(conds)
        end
      end

      def import_communes
        Terc.all(:conditions => {:pow.not => nil, :gmi.not => nil}).batch(1000) do |t|
          d = District.joins(:voivodeship).where('voivodeships.nr' => t.woj, 'districts.nr' => t.pow).first
          conds = {:nr => t.gmi, :name => Unicode.capitalize(t.nazwa), :kind => t.rodz.to_i}
          d.communes.where(conds).first || d.communes.create(conds)
        end
      end
    end

  end
end
