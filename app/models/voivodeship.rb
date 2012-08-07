# == Schema Information
#
# Table name: voivodeships
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  nr         :string(255)
#

# -*- encoding : utf-8 -*-
class Voivodeship < ActiveRecord::Base
  attr_accessible :id, :name, :nr
  has_many :districts, :dependent => :destroy
  has_many :communes, :through => :districts
  has_many :places, :through => :communes
  has_many :relics, :through => :places

  validates :name, :presence => true
end
