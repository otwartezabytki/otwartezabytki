# -*- encoding : utf-8 -*-
module Import
  class AdministrativeDivision
    class << self
      # expected args: voivodeship_name, distrct_name, commune_name, place_name
      def find_or_create *args
        raise ArgumentError.new("args: #{args.inspect}") unless args.size == 4 and args.all?(&:present?)
        voivodeship = Voivodeship.find_or_create_by_name! args[0]
        district    = voivodeship.districts.find_or_create_by_name! args[1]
        commune     = district.communes.find_or_create_by_name! args[2]
        place       = commune.places.find_or_create_by_name! args[3]
      end
    end
  end

  # terc --> GUSowska baza terytu (województwo, powiat, gmina)
  class Terc
    include DataMapper::Resource
    storage_names[:default] = 'terc'

    property :woj, String
    property :pow, String
    property :gmi, String
    property :rodz, String
    property :nazwa, String
    property :nazwadod, String
    property :stan_na, String

  end

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
    property :sym, String
    property :sympod, String
    property :stan_na, String

  end

  # ulic --> GUSowska baza kodów ulic
  class Ulic
    include DataMapper::Resource
    storage_names[:default] = 'ulic'

    property :woj, String
    property :pow, String
    property :gmi, String
    property :rodz_gmi, String
    property :sym, String
    property :sym_ul, String
    property :cecha, String
    property :nazwa_1, String
    property :nazwa_2, String
    property :stan_na, String

  end
end
