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
end
