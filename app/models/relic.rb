# -*- encoding : utf-8 -*-
class Relic < ActiveRecord::Base
  attr_accessible :dating_of_obj, :group, :id, :identification, :materail, :national_number, :number, :place_id, :register_number, :street, :internal_id, :source
  belongs_to :place

  validates :place_id, :presence => true

  has_ancestry
  serialize :source

  default_scope :order => "relics.id ASC"

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
