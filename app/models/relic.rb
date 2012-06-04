# -*- encoding : utf-8 -*-
class Relic < ActiveRecord::Base
  attr_accessible :dating_of_obj, :group, :id, :identification, :materail, :national_number, :number, :place_id, :register_number, :street, :internal_id, :source
  belongs_to :place

  validates :place_id, :presence => true

  has_ancestry
  serialize :source

  default_scope :order => "relics.id ASC"

  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :id, :index => :not_analyzed
    indexes :identification
    indexes :group
    with_options :index => :not_analyzed do |m|
      m.indexes :voivodeship_id
      m.indexes :district_id
      m.indexes :commune_id
      m.indexes :place_id
      m.indexes :ancestry
    end
  end

  Tire.configure { logger 'log/elasticsearch.log' }

  class << self
    def search(params)
      tire.search(load: true, page: params[:page]) do
        location = params[:location].to_s.split('/')
        query do
          boolean do
            must { string (params[:query].present? ? params[:query] : '*'), default_operator: "AND" }
          end
        end

        filter :term, :voivodeship_id => location[0]  if location.size > 0
        filter :term, :district_id    => location[1]  if location.size > 1
        filter :term, :commune_id     => location[2]  if location.size > 2
        filter :term, :place_id       => location[3]  if location.size > 3

        facet "voivodeships" do
          terms :voivodeship_id, size: 16
        end

        facet "districts", facet_filter: { term: { voivodeship_id: location[0] } } do
          terms :district_id, size: 10_000
        end if location.size > 0

        facet "communes", facet_filter: { term: { district_id: location[1] } } do
          terms :commune_id, size: 10_000
        end if location.size > 1

        facet "places", facet_filter: { term: { commune_id: location[2] } } do
          terms :place_id, size: 10_000
        end if location.size > 2

        sort { by :id, 'asc' }
      end
    end
  end

  def to_indexed_json
    ids = [:voivodeship_id, :district_id, :commune_id, :place_id].zip(get_parent_ids)
    {
      id: id,
      identification: identification,
      group: group,
      ancestry: ancestry
    }.merge(Hash[ids]).to_json
  end


  def full_identification
    "#{identification} (#{register_number}) datowanie: #{dating_of_obj}; ulica: #{street}"
  end

  def get_parent_ids
    [place.commune.district.voivodeship_id, place.commune.district_id, place.commune_id, place_id]
  end

  def next
    last_id = self.class.last.try(:id)
    next_id = self.id + 1
    while next_id <= last_id
      obj = self.class.find_by_id(next_id)
      return obj if obj
      next_id += 1
    end
    nil
  end

  def prev
    first_id = self.class.first.try(:id)
    prev_id = self.id - 1
    while prev_id >= first_id
      obj = self.class.find_by_id(prev_id)
      return obj if obj
      prev_id - 1
    end
    nil
  end

  def find_children
    nrelic = self.next

    if nrelic.group.blank? and nrelic.next.try(:group).present?
      nrelic.parent = self
      nrelic.save
      nrelic = nrelic.next
    end

    while nrelic.number.to_s =~ /1/ and nrelic.group.present?
      nrelic.parent = self
      nrelic.save
      nrelic = nrelic.next
    end
  end

end
