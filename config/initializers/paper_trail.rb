class Version < ActiveRecord::Base
  attr_accessible :source
  scope :relics, where(:item_type => "Relic")
  scope :documents, where(:item_type => "Document")
  scope :photos, where(:item_type => "Photo")
  scope :events, where(:item_type => "Event")
  scope :entries, where(:item_type => "Entry")
  scope :links, where(:item_type => "Link")
  
  def preview
    @preview ||= self.reify ||
    Version.where("item_type = ? AND id > ?", self.item_type, self.id).first.try(:reify) ||
    Kernel.const_get(self.item_type).where(:id => self.item_id).first
  end
end
