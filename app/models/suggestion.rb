class Suggestion < ActiveRecord::Base
  belongs_to :user
  belongs_to :relic
  belongs_to :place

  belongs_to :suggestion, :foreign_key => :ancestry

  has_many :suggestions, :dependent => :destroy, :foreign_key => :ancestry, :before_add => :propagate_subrelic_data

  accepts_nested_attributes_for :suggestions, :allow_destroy => false

  attr_accessible :relic_id, :place_id, :place_id_action, :identification, :identification_action,
                  :street, :street_action, :dating_of_obj, :dating_of_obj_action, :latitude, :longitude,
                  :coordinates_action, :tags, :tags_action, :place, :suggestions_attributes, :serialized_attr

  attr_protected :id, :created_at, :updated_at

  validates :place_id_action, :identification_action, :street_action, :dating_of_obj_action,
            :tags_action, :coordinates_action, :inclusion => { :in => ['edit', 'skip', 'confirm'] }

  scope :roots, where(:ancestry => nil)
  scope :not_skipped, where(:skipped => false)

  before_save do
    self.skipped = is_skipped?
    true
  end

  after_create  :update_relic_skip_cache

  serialize :tags, Array

  def update_relic_skip_cache
    return false if ancestry.present?
    if self.skipped
      Relic.increment_counter(:skip_count, relic_id)
    else
      Relic.increment_counter(:edit_count, relic_id)
    end
    # explicit update relic index
    self.relic.reload.update_relic_index
    true
  end

  def is_skipped?
    return @is_skipped if defined? @is_skipped
    @is_skipped = if ancestry.blank?
      self.class.relic_action_columns.all? {|c| send(c) == 'skip'} and self.suggestions.map(&:is_skipped?).all?
    else
      self.class.subrelic_action_columns.all? {|c| send(c) == 'skip'}
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
      self.tags = self.relic.tags
    end

  end

  def tags=(value)
    self[:tags] = value.select(&:present?)
  end

  def serialized_attr=(value)
    self.update_attributes(ActiveSupport::JSON.decode(value))
  end

  def serialized_attr
    if self.suggestions.size > 0
      ActiveSupport::JSON.encode({ :suggestions_attributes => self.suggestions.map(&:accessible_attributes_hash) }.merge(self.accessible_attributes_hash))
    else
      ActiveSupport::JSON.encode(self.accessible_attributes_hash)
    end
  end

  def place_id=(value)
    if value.to_i != 0
      self[:place_id] = value
    else
      place = Place.find_or_create_by_name(value) do |p|
        p.commune = self.relic.commune
        p.from_teryt = false
      end

      self[:place_id] = place.id
    end
  end

  def accessible_attributes_hash
    self.attributes.delete_if {|key, value| !self.class.accessible_attributes.include?(key) }
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
      self.relic.descendants.each do |subrelic|
        self.suggestions << Suggestion.new(:relic => subrelic)
      end
    end
  end

  def self.relic_action_columns
    [
      "place_id_action",
      "identification_action",
      "street_action",
      "dating_of_obj_action",
      "coordinates_action",
      "tags_action"
    ]
  end

  def self.subrelic_action_columns
    [
      "identification_action",
      "dating_of_obj_action",
      "tags_action"
    ]
  end

  private

  def propagate_subrelic_data(subrelic)
    subrelic.user_id = self.user_id
    subrelic.ip_address = self.ip_address
  end
end
