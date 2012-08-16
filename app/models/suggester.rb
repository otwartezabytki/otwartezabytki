class Suggester
  attr_accessor :query

  def initialize query
    @query = query.to_s.strip
  end

  def prepared_query
    return @prepared_query if defined? @prepared_query
    return nil if @query.size < 3
    split = @query.split
    # add asterisk only for last word
    split[-1] = "#{split[-1]}*"
    @prepared_query = split.join(' ')
  end

  def prepared_query?
    prepared_query.present?
  end

  def place_filter_conditions *fields
    {'facet_filter' => {'query' => {'query_string' => {'query' => prepared_query, 'fields' => fields, 'default_operator' => 'AND'}}}}
  end

  # not the best idea
  # def identification
  #   return [] unless prepared_query?
  #   instance = self
  #   search = Tire.search(Relic.tire.index_name, :size => 0) do
  #     facet "identifications", instance.place_filter_conditions('identification') do
  #       terms nil, :script_field => "_source.identification_normalized", :size => 6
  #     end
  #   end
  #   search.results
  # end

  def place
    return [] unless prepared_query?
    instance = self
    search = Tire.search(Relic.tire.index_name, :size => 0) do
      facet "voivodeships", instance.place_filter_conditions('voivodeship.name') do
        terms nil, :script_field => "_source.voivodeship.name + '_' + _source.voivodeship.id", :size => 3
      end
      facet "districts", instance.place_filter_conditions('district.name') do
        terms nil, :script_field => "_source.district.name + '_' + _source.district.id", :size => 3
      end
      facet "communes", instance.place_filter_conditions('commune.name') do
        terms nil, :script_field => "_source.commune.name + '_' + _source.virtual_commune_id", :size => 3
      end
      facet "places", instance.place_filter_conditions('place.name') do
        terms nil, :script_field => "_source.place.name + '_' + _source.place.id", :size => 3
      end
      facet "streets", instance.place_filter_conditions('street_normalized') do
        terms nil, :script_field => "_source.street_normalized + '_' + _source.place.name + '_' + _source.place.id", :size => 3
      end

    end
    search.results
  end

end