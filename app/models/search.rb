class Search
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :q, :place, :from, :to, :categories, :state, :existance, :location, :order
  attr_accessor :conditions, :page

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

  [:categories, :state, :existance].each do |name|
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
    # corrected_relic_ids = seen_relic_ids = []
    # @tsearch.sort do
    #   by '_script', {
    #       'script' => %q(
    #         i = -seen_relic_ids.indexOf(doc['id'].value.toString());
    #         f0 = (i * 100) + (doc['edit_count'].value * f1) - doc['skip_count'].value;
    #         if( corrected_relic_ids.contains(doc['id'].value.toString()) || doc['edit_count'].value > 2 ) { f2 + f0; } else { f0; }
    #       ).squish,
    #       'type' => 'number',
    #       'params' => {
    #         'f1' => 100,
    #         'f2' => -100_000_000,
    #         'corrected_relic_ids' => corrected_relic_ids,
    #         'seen_relic_ids' => seen_relic_ids
    #       },
    #       'order' => 'desc'
    #     }
    #   by '_score', 'desc'
    # end

    type, direction = order.split('.')
    @tsearch.sort do
      case type
      when 'score'
        by '_score', direction
      when 'alfabethic'
        by 'identification.untouched', direction
      when 'photo'
        by '_script', {
          'script' => '_source.has_photos ? 10 * doc.score : doc.score',
          'type' => 'number',
          'order' => direction
        }
      when 'description'
        by '_script', {
          'script' => '_source.has_description ? 10 * doc.score : doc.score',
          'type' => 'number',
          'order' => direction
        }
      else
        # default
        by '_score', 'desc'
      end
    end
  end

  def enable_correccted_facet
    location = corrected_relic_ids = []
    corrected_faset_filter = {}
    term_params = Hash[
      ['voivodeship.id', 'district.id', 'commune.id', 'place.id'].zip(location)
    ].inject({}) { |mem, (k, v)| mem[k] = v if v; mem }
    corrected_faset_filter = { :facet_filter => { :terms => term_params } } if term_params.present?

    @tsearch.facet "corrected", corrected_faset_filter do
      terms :edit_count, :script => "(corrected_relic_ids.contains(doc['id'].value.toString()) || doc['edit_count'].value > 2) ? 1 : 0", :all_terms => true, :params => {
        'corrected_relic_ids' => corrected_relic_ids
      }
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
    return {} if terms.blank?
    {
      'facet_filter' => {
        'and' => terms.map { |k, v| {"terms" => { k => v}} }
      }
    }
  end

  def prepare_conditions
    @conditions = ['categories', 'state', 'existance'].inject({}) do |r, t|
      r[t] = send(t) if send(t).present?
      r
    end
    location_conditions = Hash[
      ['voivodeship.id', 'district.id', 'commune.id', 'place.id'].zip(location)
    ].inject({}) { |mem, (k, v)| mem[k] = v if v; mem }
    @conditions.merge! location_conditions
    @conditions
  end

  def perform
    instance = self
    prepare_conditions

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

      Rails.logger.info instance.filter_facet_conditions

      facet "overall", instance.filter_facet_conditions('voivodeship.id', 'district.id', 'commune.id', 'place.id') do
        terms nil, :script_field => 1, :global => true
      end

      facet 'categories', instance.filter_facet_conditions('categories') do
        terms :categories, :size => Tag.all.size, :all_terms => true
      end

      facet 'state', instance.filter_facet_conditions('state') do
        terms :state, :all_terms => true
      end

      facet 'existance', instance.filter_facet_conditions('existance') do
        terms :existance, :all_terms => true
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