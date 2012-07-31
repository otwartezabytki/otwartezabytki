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
  attr_accessible :id, :name, :district_id, :nr, :kind
  belongs_to :district
  has_many :places, :dependent => :destroy

  validates :name, :presence => true

end
