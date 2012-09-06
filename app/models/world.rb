# encoding: utf-8

class World
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  extend WillCache::Cacheable
  include Relic::BoundingBox

  def self.find(id = nil)
    World.new
  end

  def id
    0
  end

  def name
    "Świat"
  end

  def full_name
    "Świat"
  end

  def latitude
    52.0000
  end

  def longitude
    19.0000
  end

  def up_id
    nil
  end

  def up
    nil
  end

  attr_accessor :facet_count

  def serializable_hash
    {
      :id => 0,
      :name => "Świat",
      :latitude => 0,
      :longitue => 0,
      :facet_count => facet_count
    }
  end

  def self.visible_from
    4000
  end

end