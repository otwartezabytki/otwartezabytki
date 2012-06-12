# -*- encoding : utf-8 -*-
module Import
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
end
