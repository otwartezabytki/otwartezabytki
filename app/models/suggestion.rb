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

  before_create do
    self.skipped = is_skipped?
    if self.suggestion.present? && self.user_id.blank?
      self.user_id = self.suggestion.user_id
    end
  end
  after_create  :update_relic_skip_cache

  serialize :tags, Array

  class << self
    def action_columns
      return @action_columns if defined? @action_columns
      @action_columns = self.column_names.inject([]){ |m, a| m << a if a.match(/_action/); m }
    end
  end

  def update_relic_skip_cache
    return false if ancestry.present?
    if self.skipped
      Relic.increment_counter(:skip_count, relic_id)
    else
      Relic.increment_counter(:edit_count, relic_id)
    end
    # explicit update relic index
    relic.update_relic_index
    true
  end

  def descendants
    self.class.where(:ancestry => id)
  end

  def is_skipped?
    return @is_skipped if defined? @is_skipped
    @is_skipped = if ancestry.blank?
      self.class.action_columns.all? {|c| send(c) == 'skip'} and descendants.map(&:is_skipped?).all?
    else
      self.class.action_columns.all? {|c| send(c) == 'skip'}
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
