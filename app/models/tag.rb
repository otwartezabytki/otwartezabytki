# encoding: utf-8
class Tag < ActiveRecord::Base
  attr_accessible :name

  validates :name, :uniqueness => { :message => "Nazwa kategorii jest już zajęta." }
end
