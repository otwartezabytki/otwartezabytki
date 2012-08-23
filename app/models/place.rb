# == Schema Information
#
# Table name: places
#
#  id                 :integer          not null, primary key
#  commune_id         :integer
#  name               :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  sym                :string(255)
#  from_teryt         :boolean          default(TRUE)
#  custom             :boolean          default(FALSE)
#  virtual_commune_id :string(255)
#

# -*- encoding : utf-8 -*-
class Place < ActiveRecord::Base
  attr_accessible :id, :name, :commune_id, :sym, :from_teryt
  belongs_to :commune
  has_many :relics, :dependent => :destroy

  validates :name, :presence => true

  scope :not_custom, where(:custom => false)
  scope :search, lambda {|term| where("name ILIKE ?", "%#{term}%") }

  def virtual_commune_id
    self[:virtual_commune_id] || self[:commune_id]
  end

end
