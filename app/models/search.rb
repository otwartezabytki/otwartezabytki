class Search
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :q, :place, :from, :to, :categories, :has_photos, :has_description, :states, :existence, :page
  attr_accessor :facet_filter_terms

  def page
    @page || 1
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value) if value.present?
    end if attributes.present?
  end

  def persisted?
    false
  end

  def query
    return @_q if defined? @_q
    @_q = @q.to_s.strip
    # @_q = '*' if @_q.blank?
    @_q
  end

  def categories
    @categories.reject!(&:blank?) if @categories
    @categories
  end

  def states
    @states.reject!(&:blank?) if @states
    @states
  end

  def existance
    @existance.reject!(&:blank?) if @existance
    @existance
  end

  def enable_highlight
    @tsearch.highlight "identification" => {},
      "street" => {},
      "place_full_name" => {},
      "descendants.identification" => {},
      "descendants.street" => {}
  end

  def enable_sort
    corrected_relic_ids = seen_relic_ids = []
    @tsearch.sort do
      by '_script', {
          'script' => %q(
            i = -seen_relic_ids.indexOf(doc['id'].value.toString());
            f0 = (i * 100) + (doc['edit_count'].value * f1) - doc['skip_count'].value;
            if( corrected_relic_ids.contains(doc['id'].value.toString()) || doc['edit_count'].value > 2 ) { f2 + f0; } else { f0; }
          ).squish,
          'type' => 'number',
          'params' => {
            'f1' => 100,
            'f2' => -100_000_000,
            'corrected_relic_ids' => corrected_relic_ids,
            'seen_relic_ids' => seen_relic_ids
          },
          'order' => 'desc'
        }
      by '_score', 'desc'
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
    location = [] #params[:location].to_s.split('-').map {|l| l.split(':') }
    voivodeship_facet_filter  = @facet_filter_terms.present? ? { :facet_filter => { :term => @facet_filter_terms } } : {}
    @tsearch.facet "voivodeships", voivodeship_facet_filter do
      terms nil, :script_field => "_source.voivodeship.name + '_' + _source.voivodeship.id", :size => 16, :order => 'term'
    end

    if location.size > 0
      @tsearch.filter :terms, 'voivodeship.id' => location[0]
      @tsearch.facet "districts", :facet_filter => { :term => @facet_filter_terms.merge('voivodeship.id' => location[0]) } do
        terms nil, :script_field => "_source.district.name + '_' + _source.district.id", :size => 10_000, :order => 'term'
      end
    end

    if location.size > 1
      @tsearch.filter :terms, 'district.id' => location[1]
      @tsearch.facet "communes", :facet_filter => { :term => @facet_filter_terms.merge('district.id' => location[1]) } do
        terms nil, :script_field => "_source.commune.name + '_' + _source.virtual_commune_id", :size => 10_000, :order => 'term'
      end
    end

    if location.size > 2
      @tsearch.filter :terms, 'commune.id' => location[2]
      @tsearch.facet "places", :facet_filter => { :term => @facet_filter_terms.merge('commune.id' => location[2]) } do
         terms nil, :script_field => "_source.place.name + '_' + _source.place.id", :size => 10_000, :order => 'term'
      end
    end

    @tsearch.filter :terms, 'place.id' => location[3] if location.size > 3

  end

  def perform
    data = self
    @tsearch = Tire.search(Relic.tire.index_name, :load => false, :page => page, :per_page => 10) do
      query do
        boolean do
          must { string data.query, :default_operator => "AND", :fields => [
            "identification^10",
            "descendants.identification^8"
          ]} if data.query.present?
          must { string data.place, :default_operator => "AND", :fields => [
            "place_full_name^5",
            "street^3"
          ]} if data.place.present?
        end
      end if [data.query, data.place].any? &:present?

      # facet "has_photos" do
      #   terms "has_photos"
      # end

      # facet "has_description" do
      #   terms "has_description"
      # end
      data.facet_filter_terms = {}
      if data.categories.present?
        data.facet_filter_terms['categories'] = data.categories
        filter :terms, 'categories' => data.categories, :execution => 'and'
      end
      unless data.has_photos.nil?
        data.facet_filter_terms['has_photos'] = data.has_photos
        filter :term, 'has_photos' => data.has_photos
      end
      unless data.has_description.nil?
        data.facet_filter_terms['has_description'] = data.has_description
        filter :term, 'has_description' => data.has_description
      end
      if data.states.present?
        data.facet_filter_terms['state'] = data.states
        filter :terms, 'state' => data.states, :execution => 'and'
      end
      if data.existance.present?
        data.facet_filter_terms['existence'] = data.existence
        filter :terms, 'existence' => data.existence, :execution => 'and'
      end

      overall_facet_filter  = data.facet_filter_terms.present? ? { :facet_filter => { :term => data.facet_filter_terms } } : {}
      facet "overall", overall_facet_filter do
        terms nil, :script_field => 1, :global => true
      end

    end

    # enable additions search features
    enable_facet_navigation
    enable_correccted_facet
    enable_highlight
    # enable_sort

    @tsearch.results
  end

end