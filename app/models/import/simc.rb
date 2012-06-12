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
    property :sym, String
    property :sympod, String
    property :stan_na, String

  end
end
