 # -*- encoding : utf-8 -*-
module Import
  # simc --> GUSowska baza miejscowosci
  class Simc
    include DataMapper::Resource
    storage_names[:default] = 'simc'

    property :woj, String
    property :pow, String
    property :gmi, String
    property :rodz_gmi, String
    property :rm, String
    property :mz, String
    property :nazwa, String
    property :sym, String, :key => true
    property :sympod, String
    property :stan_na, String

    class << self
      def import_all!
        Simc.all.batch(1000) do |t|
          c = ::Commune.joins(:district => :voivodeship).where(
            'voivodeships.nr' => t.woj, 'districts.nr' => t.pow, 'communes.nr' => t.gmi, 'communes.kind' => t.rodz_gmi
          ).first
          conds = {:name => Unicode.capitalize(t.nazwa), :sym => t.sym}
          c.places.where(conds).first || c.places.create(conds)
        end
      end
    end

  end
end
