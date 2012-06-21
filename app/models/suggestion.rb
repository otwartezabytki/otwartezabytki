class Suggestion < ActiveRecord::Base
  belongs_to :user
  belongs_to :relic
  belongs_to :place

  attr_accessible :relic_id, :place_id, :place_id_action, :identification, :identification_action,
                  :street, :street_action, :dating_of_obj, :dating_of_obj_action, :latitude, :longitude,
                  :coordinates_action, :tags, :tags_action

  validates :place_id_action, :identification_action, :street_action,
            :dating_of_obj_action, :coordinates_action, :inclusion => { :in => ['edit', 'skip', 'confirm'] }

  serialize :tags, Array

  def place_name
    self.relic.place.name
  end

  after_initialize do
    if self.relic.present?
      self.place = self.relic.place
      self.identification = self.relic.identification
      self.street = self.relic.street
      self.dating_of_obj = self.relic.dating_of_obj
      self.latitude = self.relic.latitude
      self.longitude = self.relic.longitude
    end
  end

  def latitude
    self[:latitude].present? ? self[:latitude].round(6) : nil
  end

  def longitude
    self[:longitude].present? ? self[:longitude].round(6) : nil
  end
end
