class Search
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :q, :place, :from, :to, :categories, :state, :existance, :location, :order
  attr_accessor :conditions, :range_conditions, :page, :has_photos, :has_description

  def initialize(attributes = {})
    attributes.each do |name, value|
      next if value.blank?
      send("#{name}=", value)
    end if attributes.present?
  end

  def persisted?
    false
  end

  def query
    return @_q if defined? @_q
    @_q = @q.to_s.strip
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

  def enable_highlight
    @tsearch.highlight "identification" => {},
      "street" => {},
      "place_full_name" => {},
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
    @tsearch.facet "voivodeships", filter_facet_conditions do
      terms nil, :script_field => "_source.voivodeship.name + '_' + _source.voivodeship.id", :size => 16, :order => 'term'
    end

    @tsearch.facet "districts", filter_facet_conditions do
      terms nil, :script_field => "_source.district.name + '_' + _source.district.id", :size => 10_000, :order => 'term'
    end if location.size > 0

    @tsearch.facet "communes", filter_facet_conditions do
      terms nil, :script_field => "_source.commune.name + '_' + _source.virtual_commune_id", :size => 10_000, :order => 'term'
    end if location.size > 1

    @tsearch.facet "places", filter_facet_conditions do
       terms nil, :script_field => "_source.place.name + '_' + _source.place.id", :size => 10_000, :order => 'term'
    end if location.size > 2
  end

  def filter_facet_conditions *keys
    terms = @conditions.except(*keys)
    terms_cond = []
    terms_cond = terms.map { |k, v| {"terms" => { k => v}} } if terms.present?
    terms_cond << { 'or' => @range_conditions } if range_conditions?
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
    location_conditions = Hash[
      ['voivodeship.id', 'district.id', 'commune.id', 'place.id'].zip(location)
    ].inject({}) { |mem, (k, v)| mem[k] = v if v; mem }
    @conditions.merge! location_conditions
    @conditions
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

  def perform
    instance = self
    build_conditions
    build_range_conditions

    @tsearch = Tire.search(Relic.tire.index_name, :page => page, :per_page => 10) do
      # pagination
      size( options[:per_page].to_i ) if options[:per_page]
      from( options[:page].to_i <= 1 ? 0 : (options[:per_page].to_i * (options[:page].to_i-1)) ) if options[:page] && options[:per_page]

      # query
      query do
        boolean do
          must { string instance.query, :default_operator => "AND", :fields => [
            "identification^10",
            "descendants.identification^8"
          ]} if instance.query.present?
          must { string instance.place, :default_operator => "AND", :fields => [
            "place_full_name^5",
            "street^3"
          ]} if instance.place.present?
        end
      end if [instance.query, instance.place].any? &:present?

      instance.conditions.each { |k, v| filter :terms, k => v }
      filter 'or', instance.range_conditions if instance.range_conditions?

      facet "overall", instance.filter_facet_conditions('voivodeship.id', 'district.id', 'commune.id', 'place.id') do
        terms nil, :script_field => 1, :global => true
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

    # enable additions search features
    enable_facet_navigation
    enable_highlight
    enable_sort

    @tsearch.results
  end

  def suggestions
    return [] unless @tsearch.results.total.zero?
    KeywordStat.search KeywordStat.spellcheck(query)
  end

end