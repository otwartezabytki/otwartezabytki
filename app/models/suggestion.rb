class Suggestion < ActiveRecord::Base
  belongs_to :user
  belongs_to :relic
  belongs_to :place

  belongs_to :suggestion, :foreign_key => :ancestry
  has_many :suggestions, :dependent => :destroy, :foreign_key => :ancestry

  accepts_nested_attributes_for :suggestions, :allow_destroy => false

  attr_accessible :relic_id, :place_id, :place_id_action, :identification, :identification_action,
                  :street, :street_action, :dating_of_obj, :dating_of_obj_action, :latitude, :longitude,
                  :coordinates_action, :tags, :tags_action, :place, :suggestions_attributes

  attr_protected :id, :created_at, :updated_at

  validates :place_id_action, :identification_action, :street_action,
            :dating_of_obj_action, :coordinates_action, :inclusion => { :in => ['edit', 'skip', 'confirm'] }

  serialize :tags, Array

  def before_create
    if self.suggestion.present? && self.user_id.blank?
      self.user_id = self.suggestion.user_id
    end
  end

  def place_name
    self.relic.place.name
  end

  def relic_id=(value)
    self[:relic_id] = value

    if self.relic_id_changed?
      self.place_id = self.relic.place_id
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

  def fill_subrelics
    # only one level of suggestions
    if self.suggestion.nil?
      self.suggestions.destroy_all
      self.relic.descendant_ids.each do |subrelic_id|
        self.suggestions << Suggestion.new(:relic_id => subrelic_id)
      end
    end
  end
end
