# -*- encoding : utf-8 -*-
module Import
  # registry --> rejestr zabytków, jaki dostaliśmy w zeszłym tygodniu z NIDu
  class Register
    include DataMapper::Resource
    storage_names[:default] = 'registry'

    property :nid_id, Integer, :key => true
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

    class << self
      def import_all!
        Register.all.batch(1000) do |t|
          next if ::Relic.find_by_nid_id(t.nid_id.to_s)
          place = ::Place.find_by_sym(t.clean_location.try(:cit_t))

          ::Relic.create(
            :identification   => t.name,
            :kind             => t.type,
            :nid_id           => t.nid_id,
            :street           => t.street,
            :register_number  => t.number,
            :register_date    => t.date_reg,
            :dating_of_obj    => t.date,
            :date_norm        => t.date_norm,
            :date_start       => t.date_start,
            :date_end         => t.date_end,
            :source_type      => 'nid',
            :place            => place
          )
        end
      end
    end

    def clean_data
      CleanData.first(:nid_id => nid_id)
    end

    def clean_location
      CleanLocation.first(:nid_id => nid_id)
    end

  end
end