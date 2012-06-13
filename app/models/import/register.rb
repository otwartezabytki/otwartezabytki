# -*- encoding : utf-8 -*-
module Import
  # registry --> rejestr zabytków, jaki dostaliśmy w zeszłym tygodniu z NIDu
  class Register
    include DataMapper::Resource
    storage_names[:default] = 'registry'

    property :nid_id, Integer
    property :voi, String
    property :pov, String
    property :par, String
    property :city, String
    property :name, String
    property :number, String
    property :date_reg, String
    property :date, String
    property :date_norm, String
    property :date_start, String
    property :date_end, String
    property :type, String
    property :par_nr, String
    property :pov_nr, String
    property :voi_nr, String
    property :par_type, String
    property :street, String

    def clean_data
      CleadData.first(:nid_id => nid_id)
    end

    def clean_location
      CleadLocation.first(:nid_id => nid_id)
    end

  end
end