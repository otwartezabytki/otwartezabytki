# -*- encoding : utf-8 -*-
class Search
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :q, :query, :place, :from, :to, :categories, :state, :existence, :location, :order, :lat, :lon, :load
  attr_accessor :conditions, :range_conditions, :per_page, :page, :has_photos, :has_description, :facets, :zoom, :widget
  attr_accessor :bounding_box, :radius, :path, :polygon, :waypoints, :route_type, :distance

  def initialize(attributes = {})
    attributes.each do |name, value|
      next if value.blank? or !respond_to?("#{name}=")
      send("#{name}=", value)
    end if attributes.present?
  end

  def persisted?
    false
  end

  def load100
    !!@load
  end

  def radius=(value)
    @radius = value
  end

  def radius
    @radius || 5
  end

  def path=(value)
    @path = value.split(";").map{ |vertex| vertex.split(',').map(&:to_f) }
  end

  def path
    @path
  end

  def widget=(value)
    @widget = value
  end

  def query
    return @_q if defined? @_q
    @_q = (@q || @query).to_s.strip.gsub(/['"]/i, '')
    @_q
  end

  [:state, :existence, :has_photos, :has_description].each do |name|
    define_method name do
      variable = instance_variable_get("@#{name}")
      return [] if variable.blank?
      variable = variable.split(',') if variable.kind_of?(String)
      variable.reject(&:blank?)
    end
  end

  def boundary
    return nil if @path.nil? || @radius.nil?
    @boundary ||= Polygon.expand(path, @radius.to_f)
  end

  def categories
    return @cached_categories if defined? @cached_categories
    if @categories.blank?
      @cached_categories = []
    else
      @cached_categories = @categories.split(',') if @categories.kind_of?(String)
      @cached_categories ||= @categories.reject(&:blank?)
      @cached_categories << 'sakralny' if !@cached_categories.include?('sakralny') and @cached_categories.any? { |c| Category.sacral.pluck(:name_key).include?(c) }
      Rails.logger.info "cat: #{@cached_categories.inspect}"
    end
    @cached_categories
  end

  def bounding_box=(value)
    @top_left, @bottom_right = value.split(';')
  end

  def bounding_box?
    @top_left.present? && @bottom_right.present?
  end

  def location_object
    @location_object
  end

  def polygon=(value)
    @polygon = value.split(';')
  end

  def polygon
    @polygon
  end

  def polygon?
    @polygon.present?
  end

  def distance=(value)
    value = value.try(:gsub, ',', '.').try(:to_f) || 0
    @distance = [value, 0.2].max
  end

  def distance
    @distance || 0.2
  end

  def location=(value)
    _, location_type, location_ids = value.match('^(world|country|voivodeship|district|commune|place):(.*)$').to_a
    location_ids = location_ids.split(',') if location_ids.present?

    @location = if location_type.present? && location_ids.present? && location_ids.length > 0
      case location_type
        when 'world'
          @location_object = World.new
          []
        when 'country'
          @location_object = Country.find(location_ids.first)
          [location_ids]
        when 'voivodeship'
          @location_object = Voivodeship.find(location_ids.first)
          [['pl'], location_ids]
        when 'district'
          @location_object = District.find(location_ids.first)
          voivodeship_ids = District.where(:id => location_ids).map(&:voivodeship_id).uniq.map(&:to_s)
          [['pl'], voivodeship_ids, location_ids]
        when 'commune'
          @location_object = Commune.find(location_ids.first)
          district_ids = Commune.where(:id => location_ids).map(&:district_id).uniq.map(&:to_s)
          voivodeship_ids = District.where(:id => district_ids).map(&:voivodeship_id).uniq.map(&:to_s)
          [['pl'], voivodeship_ids, district_ids, location_ids]
        when 'place'
          @location_object = Place.find(location_ids.first)
          commune_ids = Place.where(:id => location_ids).map{ |p| p.commune.virtual_id.split(',') }.flatten.uniq.map(&:to_s)
          district_ids = Commune.where(:id => commune_ids).map(&:district_id).uniq.map(&:to_s)
          voivodeship_ids = District.where(:id => district_ids).map(&:voivodeship_id).uniq.map(&:to_s)
          [['pl'], voivodeship_ids, district_ids, commune_ids, location_ids]
        else
          []
      end
    else
      value.to_s.split('-').map {|l| l.split(':') }
    end
  end

  def location
    @location || ['pl']
  end

  def facets
    available_facets = if widget == 'direction'
      ["countries", "districts", "communes", "places"]
    else
      ["countries", "voivodeships", "districts", "communes", "places"]
    end
    navbar_facets = available_facets.drop(location.length)

    if bounding_box?
      visible_facets = [World, Country, Voivodeship, District, Commune, Place].each_cons(2).to_a.select{ |e| e.first.visible_from >= bounding_box_size }
        .map(&:last).map(&:name).map(&:downcase).map(&:pluralize)

      first_navbar_facet = navbar_facets.first
      navbar_facets &= visible_facets
      if navbar_facets.blank? && bounding_box_size > Commune.visible_from
        navbar_facets = [first_navbar_facet || "places"]
      end
    else
      navbar_facets = navbar_facets[0..0]
    end

    navbar_facets
  end

  def order
    @order || 'score.desc'
  end

  def per_page
    @per_page || 30
  end

  def per_page=(value)
    @per_page = value
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
    if @widget
      @tsearch.facet "countries", filter_facet_conditions('country') do
        terms 'country', :size => 200, :order => 'term'
      end if facets.include?("countries")

      @tsearch.facet "voivodeships", filter_facet_conditions('voivodeship.id', 'district.id', 'commune.id', 'place.id') do
        terms nil, :script_field => "_source.voivodeship.name + '_' + _source.voivodeship.id", :size => 16, :order => 'term'
      end if facets.include?("voivodeships")

      @tsearch.facet "districts", filter_facet_conditions('district.id', 'commune.id', 'place.id') do
        terms nil, :script_field => "_source.district.name + '_' + _source.district.id", :size => 100, :order => 'term'
      end if facets.include?("districts")

      @tsearch.facet "communes", filter_facet_conditions('commune.id', 'place.id') do
        terms nil, :script_field => "_source.commune.name + '_' + _source.virtual_commune_id", :size => 100, :order => 'term'
      end if facets.include?("communes")

      @tsearch.facet "places", filter_facet_conditions('place.id') do
        terms nil, :script_field => "_source.place.name + '_' + _source.place.id", :size => 500, :order => 'term'
      end if facets.include?("places")
    else
      if navfacet?('pl')

        @tsearch.facet "voivodeships", filter_facet_conditions('voivodeship.id', 'district.id', 'commune.id', 'place.id') do
          terms nil, :script_field => "_source.voivodeship.name + '_' + _source.voivodeship.id", :size => 16, :order => 'term'
        end if location.size > 0

        @tsearch.facet "districts", filter_facet_conditions('district.id', 'commune.id', 'place.id') do
          terms nil, :script_field => "_source.district.name + '_' + _source.district.id", :size => 100, :order => 'term'
        end if location.size > 1

        @tsearch.facet "communes", filter_facet_conditions('commune.id', 'place.id') do
          terms nil, :script_field => "_source.commune.name + '_' + _source.virtual_commune_id", :size => 100, :order => 'term'
        end if location.size > 2

        @tsearch.facet "places", filter_facet_conditions('place.id') do
          terms nil, :script_field => "_source.place.name + '_' + _source.place.id", :size => 500, :order => 'term'
        end if location.size > 3
      end

      if navfacet?('world')
        @tsearch.facet "countries", filter_facet_conditions('country') do
          terms 'country', :size => 200, :order => 'term'
        end
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

  def sacral_facet_conditions
    # get sacral categories names
    sacral_categories = Category.sacral.pluck(:name_key)
    # choose only selected sacral categories from categories attribute
    filter_categories_array = categories.select {|s| sacral_categories.include?(s)}
    # when no category selected we should choose everything
    filter_categories_array = sacral_categories if filter_categories_array.empty?
    # return facet_filter conditions
    {
      "facet_filter" => {
        # skip categories from conditions, and use only the chosen one
        "and" => array_conditions('categories') << { 'terms' => {
          'categories' => filter_categories_array }
        }
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

  def global_filter_conditions name
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
    @conditions = ['categories', 'state', 'existence', 'has_photos', 'has_description'].inject({}) do |r, t|
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
    terms_cond = terms.map { |k, v| {"terms" => { k => v }} }      if terms.present?
    terms_cond << { 'or' => @range_conditions }                    if range_conditions?
    terms_cond << { 'term' => { 'country' => @country } }    if @country.present?
    terms_cond << { 'term' => { 'country' => 'pl'} }               if !keys.include?('pl')    and navfacet?('pl')
    terms_cond << { 'not' => { 'term' => { 'country' => 'pl'}} }   if !keys.include?('world') and navfacet?('world')

    if [@lat, @lon].all?(&:present?)
      terms_cond << {
        'geo_distance' => {
          'distance' => "#{distance}km",
          'coordinates' => [@lon, @lat]
        }
      }
    end
    if bounding_box?
      terms_cond << {
        'geo_bounding_box' => {
          'coordinates' => {
            "top_left" => @top_left,
            "bottom_right" => @bottom_right
          }
        }
      }
    end
    if boundary.present?
      terms_cond << {
        'geo_polygon' => {
          'coordinates' => {
            'points' => boundary.map { |vertex| "#{vertex.first}, #{vertex.last}" }
          }
        }
      }
    end
    if polygon?
      terms_cond << {
        'geo_polygon' => {
          'coordinates' => {
            'points' => polygon
          }
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
        boolean(:minimum_number_should_match => 1) do
          if instance.query.present?
            should { string instance.query, 'default_field' => "identification",              'default_operator' => 'AND', 'boost' => 10 }
            should { string instance.query, 'default_field' => "descendants.identification",  'default_operator' => 'AND', 'boost' => 8 }
            should { string instance.query, 'default_field' => "common_name",                 'default_operator' => 'AND', 'boost' => 6 }
            should { string instance.query, 'default_field' => "descendants.common_name",     'default_operator' => 'AND', 'boost' => 5 }
            should { string instance.query, 'default_field' => "tags",                        'default_operator' => 'AND', 'boost' => 3 }
            should { string instance.query, 'default_field' => "autocomplitions",             'default_operator' => 'AND', 'boost' => 1 }
          end
          if instance.place.present?
            must { string instance.place, :default_operator => "AND", :fields => ["place_with_address^5", "street^3"] }
          end
        end
      end if [instance.query, instance.place].any? &:present?

      filter 'and',instance.array_conditions if instance.array_conditions.present?
      filter 'or', instance.range_conditions if instance.range_conditions?

      ['overall', 'world', 'poland'].each do |name|
        facet name, instance.global_filter_conditions(name) do
          terms nil, :script_field => 1, :global => true
        end
      end

      facet 'categories', instance.filter_facet_conditions('categories') do
        terms :categories, :size => Category.all.size, :all_terms => true
      end
      facet 'sacral', instance.sacral_facet_conditions do
        terms nil, :script_field => 1
      end

      ['state', 'existence', 'has_photos', 'has_description'].each do |name|
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
        terms 'autocomplitions.untouched', 'size' => 5, 'script' => "term ~= regexp ? true : false", 'params' => {
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
        terms 'tags.untouched', 'size' => 10, 'script' => "term ~= regexp ? true : false", 'params' => {
          'regexp' => pq.regexp
        }
      end if pq.exists?
    end
    @tsearch.results.facets['tags']['terms'].map{ |term| term['term'] }
  rescue
    []
  end

  def suggestions
    return [] unless @tsearch.results.total.zero?
    pq = PreparedQuery.new Autocomplition.spellcheck(query)
    Autocomplition.where(["name ~* ?", pq.regexp]).order('count DESC').limit(5)
  end

  private

  def bounding_box_size
    if @top_left && @bottom_right
      top_left = @top_left.split(',')
      bottom_right = @bottom_right.split(',')

      @bounding_box_size ||= [
        haversine_distance(top_left.first, top_left.last, top_left.first, bottom_right.last),
        haversine_distance(top_left.first, top_left.last, bottom_right.first, top_left.last)
      ].min * 0.96
    end
  end

  def haversine_distance( lat1, lon1, lat2, lon2 )

    dlon = lon2.to_f - lon1.to_f
    dlat = lat2.to_f - lat1.to_f

    dlon_rad = dlon * Math::PI / 180.0
    dlat_rad = dlat * Math::PI / 180.0

    lat1_rad = lat1.to_f * Math::PI / 180.0
    lat2_rad = lat2.to_f * Math::PI / 180.0

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math.asin( Math.sqrt(a))

    6371 * c # radius of earth times angle
  end

end
