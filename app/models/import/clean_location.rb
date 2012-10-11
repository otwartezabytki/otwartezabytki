# -*- encoding : utf-8 -*-
module Import
  # clean_locations --> zmatchowane za pomocą kolumny nid_id
  # zabytki z rejestru z aktualnym podziałem
  # administracyjnym wg GUS
  class CleanLocation
    include DataMapper::Resource
    storage_names[:default] = 'clean_locations'

    property :nid_id, Integer, :key => true
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
