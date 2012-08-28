# == Schema Information
#
# Table name: districts
#
#  id             :integer          not null, primary key
#  voivodeship_id :integer
#  name           :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  nr             :string(255)
#

# -*- encoding : utf-8 -*-
class District < ActiveRecord::Base
  include GeocodeViewport
  attr_accessible :id, :name, :voivodeship_id, :nr
  belongs_to :voivodeship
  has_many :communes, :dependent => :destroy
  has_many :places, :through => :communes

  validates :name, :presence => true

  def address
    ['Polska', voivodeship.name, name].join(', ')
  end
end
