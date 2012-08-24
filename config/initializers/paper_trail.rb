class Version < ActiveRecord::Base
  attr_accessible :source
  scope :relics, where(:item_type => "Relic")
  scope :documents, where(:item_type => "Document")
  scope :photos, where(:item_type => "Photo")
  scope :events, where(:item_type => "Event")
  scope :entries, where(:item_type => "Entry")
  scope :links, where(:item_type => "Link")
end
