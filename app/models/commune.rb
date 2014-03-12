# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: communes
#
#  id          :integer          not null, primary key
#  district_id :integer
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  nr          :string(255)
#  kind        :integer
#

# -*- encoding : utf-8 -*-
class Commune < ActiveRecord::Base
  include GeocodeViewport
  include Relic::BoundingBox

  attr_accessible :id, :name, :district_id, :nr, :kind
  belongs_to :district
  has_many :places, dependent: :destroy

  validates :name, presence: true

  attr_accessor :facet_count

  def places
    Place.where(commune_id: virtual_ids)
  end

  def full_name
    "gm. #{name}"
  end

  def address
    ['Polska', district.voivodeship.name, district.name, name].join(', ')
  end

  def up_id
    district_id
  end

  def up
    district
  end

  def self.visible_from
    30
  end

  def virtual_ids
    @virtual_ids ||= virtual_id.split(',')
  end

  def virtual_id
    @virtual_id ||= read_attribute(:virtual_id).presence || id.to_s
  end
end
