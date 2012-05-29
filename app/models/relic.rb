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
    indexes :voivodeship_id, :as => lambda {|r| r.place.commune.district.voivodeship_id }
    indexes :district_id, :as => lambda {|r| r.place.commune.district_id }
    indexes :commune_id, :as => lambda {|r| r.place.commune_id }
    indexes :place_id
  end

  class << self
    def search(params)
      tire.search(load: true, page: params[:page]) do
        query { string params[:query] } if params[:query].present?
        filter :term, :voivodeship_id => params[:voivodeship_id]  if params[:voivodeship_id].present?
        filter :term, :district_id => params[:district_id]  if params[:district_id].present?
        filter :term, :commune_id => params[:commune_id]  if params[:commune_id].present?

        sort { by :id, 'asc' }


        facet "voivodeships" do
          terms :voivodeship_id
        end
        facet "districts" do
          terms :district_id
        end
        facet "communes" do
          terms :commune_id
        end
        facet "places" do
          terms :place_id
        end
      end
    end
  end


  def full_identification
    "#{identification} (#{register_number}) datowanie: #{dating_of_obj}; ulica: #{street}"
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
