class Search
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :q, :place, :from, :to, :categories, :state, :existance, :location, :order, :lat, :lon, :load
  attr_accessor :conditions, :range_conditions, :per_page, :page, :has_photos, :has_description

  def initialize(attributes = {})
    attributes.each do |name, value|
      next if value.blank? or !respond_to?("#{name}=")
      send("#{name}=", value)
    end if attributes.present?
  end

  def persisted?
    false
  end

  def load
    !!@load
  end

  def query
    return @_q if defined? @_q
    @_q = @q.to_s.strip.gsub(/['"]/i, '')
    @_q
  end

  [:categories, :state, :existance, :has_photos, :has_description].each do |name|
    define_method name do
      return [] if instance_variable_get("@#{name}").blank?
      instance_variable_get("@#{name}").reject!(&:blank?)
      instance_variable_get("@#{name}")
    end
  end

  def location
    @location.to_s.split('-').map {|l| l.split(':') }
  end

  def order
    @order || 'score.desc'
  end

  def per_page
    @per_page || 10
  end

  def enable_highlight
    @tsearch.highlight "identification" => {},
      "street" => {},
      "place_with_address" => {},
      "descendants.identification" => {},
      "descendants.street" => {}
  end

  def enable_sort
    type, direction = order.split('.')
    instance = self
    @tsearch.sort do
      if type == 'alfabethic'
        by 'identification.untouched', direction
      elsif instance.range_conditions?
        by '_script', {
          'script' => %q(
            if(_source.has_round_date) { doc.score; } else { doc.score * 100; }
          ).squish,
          'type' => 'number',
          'order' => direction
        }
      else
        by '_score', direction
      end
    end
  end

  def enable_facet_navigation
    if navfacet?('pl')
      @tsearch.facet "voivodeships", filter_facet_conditions('voivodeship.id', 'district.id', 'commune.id', 'place.id') do
        terms nil, :script_field => "_source.voivodeship.name + '_' + _source.voivodeship.id", :size => 16, :order => 'term'
      end

      @tsearch.facet "districts", filter_facet_conditions('district.id', 'commune.id', 'place.id') do
        terms nil, :script_field => "_source.district.name + '_' + _source.district.id", :size => 10_000, :order => 'term'
      end if location.size > 1

      @tsearch.facet "communes", filter_facet_conditions('commune.id', 'place.id') do
        terms nil, :script_field => "_source.commune.name + '_' + _source.virtual_commune_id", :size => 10_000, :order => 'term'
      end if location.size > 2

      @tsearch.facet "places", filter_facet_conditions('place.id') do
         terms nil, :script_field => "_source.place.name + '_' + _source.place.id", :size => 10_000, :order => 'term'
      end if location.size > 3
    elsif navfacet?('world')
      @tsearch.facet "countires", filter_facet_conditions('country') do
        terms 'country', :size => 10_000, :order => 'term'
      end
    end
  end

  def filter_facet_conditions *keys
    terms_cond = array_conditions *keys
    return {} if terms_cond.blank?
    {
      'facet_filter' => {
        'and' => terms_cond
      }
    }
  end

  def autocomplete_place_conds *fields
    terms_cond = array_conditions
    pq = PreparedQuery.new(place)
    if pq.exists?
      terms_cond << {'query' => {'query_string' => {'query' => pq.build, 'fields' => fields, 'default_operator' => 'AND'}}}
    end
    return {} if terms_cond.blank?
    {
      'facet_filter' => {
        'and' => terms_cond
      }
    }
  end

  def gloabl_filter_conditions name
    terms_cond = array_conditions 'world', 'pl', 'voivodeship.id', 'district.id', 'commune.id', 'place.id', 'country'
    terms_cond << { 'term' => { 'country' => 'pl'}}               if name == 'poland'
    terms_cond << { 'not' => { 'term' => { 'country' => 'pl'}} }  if name == 'world'
    return {} if terms_cond.blank?
    {
      'facet_filter' => {
        'and' => terms_cond
      }
    }
  end

  def build_conditions
    @conditions = ['categories', 'state', 'existance', 'has_photos', 'has_description'].inject({}) do |r, t|
      r[t] = send(t) if send(t).present?
      r
    end
    location_zip = location.first.to_s.include?('pl') ? ['navfacet', 'voivodeship.id', 'district.id', 'commune.id', 'place.id'] : ['navfacet', 'country']
    location_conditions = Hash[
      location.zip(location_zip).map(&:reverse)
    ]
    @conditions.merge! location_conditions
    @conditions
  end

  def navfacet? name
    @conditions['navfacet'].try(:include?, name)
  end

  def array_conditions *keys
    keys ||= []
    terms = @conditions.except *(keys << 'navfacet')
    terms_cond = []
    terms_cond = terms.map { |k, v| {"terms" => { k => v}} }      if terms.present?
    terms_cond << { 'or' => @range_conditions }                   if range_conditions?
    terms_cond << { 'term' => { 'country' => 'pl'}}               if !keys.include?('pl')    and navfacet?('pl')
    terms_cond << { 'not' => { 'term' => { 'country' => 'pl'}} }  if !keys.include?('world') and navfacet?('world')
    if [@lat, @lon].all?(&:present?)
      terms_cond << {
        'geo_distance' => {
          'distance' => '0.2km',
          'coordinates' => [@lon, @lat]
        }
      }
    end
    terms_cond
  end

  def build_range_conditions
    cond = [['from', 'gte'], ['to', 'lte']]
    values = [@from, @to].map(&:to_i)
    cond1 = cond2 = {}

    cond1 = values.each_with_index.inject({}) do |mem, (e, i)|
      key1, key2 = cond[i]
      mem[key1] = { key2 => e } if e > 0
      mem
    end

    cond2 = DateParser.round_range(*values).each_with_index.inject({}) do |mem, (e, i)|
      key1, key2 = cond[i]
      mem[key1] = { key2 => e } if e > 0
      mem
    end if values.all? { |v| v > 0 }

    cond3 = [[cond1, {'has_round_date' => false}], [cond2, {'has_round_date' => true}]].map do |c|
      range, term = c
      {'and' => [{'range' => range}, {'term' => term}]} if range.present?
    end.compact
    @range_conditions = cond3.present? ? cond3 : []
    @range_conditions
  end

  def range_conditions?
    @range_conditions.present?
  end

  def build_tsearch
    instance = self
    build_conditions
    build_range_conditions

    @tsearch = Tire.search(Relic.tire.index_name, :page => page, :per_page => per_page, :load => load) do
      # pagination
      size( options[:per_page].to_i ) if options[:per_page]
      from( options[:page].to_i <= 1 ? 0 : (options[:per_page].to_i * (options[:page].to_i-1)) ) if options[:page] && options[:per_page]

      # query
      query do
        boolean do
          if instance.query.present?
            should { text "identification",               instance.query, 'operator' => 'AND', 'boost' => 10 }
            should { text "descendants.identification",   instance.query, 'operator' => 'AND', 'boost' => 8 }
            should { text "autocomplitions",              instance.query, 'operator' => 'AND', 'boost' => 1 }
          end
          if instance.place.present?
            should { text "place_with_address", instance.place, 'operator' => 'AND', 'boost' => 5 }
          end
        end
      end if [instance.query, instance.place].any? &:present?

      filter 'and',instance.array_conditions if instance.array_conditions.present?
      filter 'or', instance.range_conditions if instance.range_conditions?

      ['overall', 'world', 'poland'].each do |name|
        facet name, instance.gloabl_filter_conditions(name) do
          terms nil, :script_field => 1, :global => true
        end
      end

      facet 'categories', instance.filter_facet_conditions('categories') do
        terms :categories, :size => Category.all.size, :all_terms => true
      end

      ['state', 'existance', 'has_photos', 'has_description'].each do |name|
        facet name, instance.filter_facet_conditions(name) do
          terms name, :all_terms => true
        end
      end
    end
  end

  def perform
    build_tsearch
    # enable additions search features
    enable_facet_navigation
    enable_highlight
    enable_sort
    @tsearch.results
  end

  def autocomplete_name
    instance = self
    build_conditions
    build_range_conditions

    @tsearch = Tire.search(Relic.tire.index_name, :size => 0) do
      # query
      query do
        string instance.place, :default_operator => "AND", :fields => [
            "place_with_address^5",
            "street^3"
          ]
      end if instance.place.present?

      filter 'and',instance.array_conditions if instance.array_conditions.present?
      filter 'or', instance.range_conditions if instance.range_conditions?
      pq = PreparedQuery.new(instance.query)
      facet "autocomplitions" do
        terms 'autocomplitions.untouched', 'size' => 20, 'script' => "term ~= regexp ? true : false", 'params' => {
          'regexp' => pq.regexp
        }
      end if pq.exists?
    end
    @tsearch.results
  end

  def autocomplete_place
    instance = self
    build_conditions
    build_range_conditions

    @tsearch = Tire.search(Relic.tire.index_name, :size => 0) do
      # query
      query do
        string instance.query, :default_operator => "AND", :fields => [
          "identification^10",
          "descendants.identification^8",
          "autocomplitions"
        ]
      end if instance.query.present?

      filter 'and',instance.array_conditions if instance.array_conditions.present?
      filter 'or', instance.range_conditions if instance.range_conditions?

      facet "voivodeships", instance.autocomplete_place_conds('voivodeship.name') do
        terms nil, :script_field => "_source.voivodeship.name + '_' + _source.voivodeship.id", :size => 3
      end
      facet "districts", instance.autocomplete_place_conds('district.name') do
        terms nil, :script_field => "_source.district.name + '_' + _source.district.id", :size => 3
      end
      facet "communes", instance.autocomplete_place_conds('commune.name') do
        terms nil, :script_field => "_source.commune.name + '_' + _source.virtual_commune_id", :size => 3
      end
      facet "places", instance.autocomplete_place_conds('place.name') do
        terms nil, :script_field => "_source.place.name + '_' + _source.place.id", :size => 3
      end
      facet "streets", instance.autocomplete_place_conds('street_normalized') do
        terms nil, :script_field => "doc['street_normalized.untouched'].value + '_' + _source.place.name + '_' + _source.place.id", :size => 3
      end
    end
    @tsearch.results
  end

  def autocomplete_tags
    instance = self
    @tsearch = Tire.search(Relic.tire.index_name, :size => 0) do
      pq = PreparedQuery.new(instance.query)
      facet "tags" do
        terms 'tags', 'size' => 20, 'script' => "term ~= regexp ? true : false", 'params' => {
          'regexp' => pq.regexp
        }
      end if pq.exists?
    end
    @tsearch.results
  end

  def suggestions
    return [] unless @tsearch.results.total.zero?
    pq = PreparedQuery.new Autocomplition.spellcheck(query)
    Autocomplition.where(["name ~* ?", pq.regexp]).order('count DESC').limit(5)
  end
end