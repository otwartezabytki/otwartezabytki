 # -*- encoding : utf-8 -*-
module Import
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

    def name
      ([cecha, nazwa_2, nazwa_1] - ['inne', 'rondo', 'rynek', 'skwer']).join(' ').gsub(/\s{2,}/, '').strip
    end

  end
end