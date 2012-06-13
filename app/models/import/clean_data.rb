# -*- encoding : utf-8 -*-
module Import

  # clean_data --> zmatchowane nasze poprawki z grudnia z danymi
  # rejestru za pomocą kolumny nid_id
  class CleanData
    include DataMapper::Resource
    storage_names[:default] = 'clean_data'

    property :nid_id,           Integer, :key => true
    property :akt_nr_rej,       String
    property :wojewodztwo,      String
    property :powiat,           String
    property :gmina,            String
    property :miejscowosc,      String
    property :ulica,            String
    property :okr_ob,           String
    property :okr_zes,          String
    property :datowanie_ob,     String
    property :teryt,            String
    property :geo1,             String
    property :lat1,             String
    property :long1,            String
    property :geo2,             String
    property :lat2,             String
    property :long2,            String
    property :approved,         String
    property :comments,         String
    property :__akt_nr_rej__,   String
    property :__datowanie_ob__, String
    property :__geo1__,         String
    property :__gmina__,        String
    property :__miejscowosc__,  String
    property :__okr_ob__,       String
    property :__okr_zes__,      String
    property :__powiat__,       String
    property :__ulica__,        String
    property :mongo_id,         String

  end

  # clean_locations --> zmatchowane za pomocą kolumny nid_id
  # zabytki z rejestru z aktualnym podziałem
  # administracyjnym wg GUS
  class CleanLocation
    include DataMapper::Resource
    storage_names[:default] = 'clean_locations'

    property :nid_id, Integer
    property :voi, String
    property :pov, String
    property :par, String
    property :cit, String

    property :voi_t, String
    property :pov_t, String
    property :par_t, String
    property :cit_t, String
    property :teryt, String

  end
end