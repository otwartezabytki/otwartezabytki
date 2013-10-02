# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  relic_id   :integer
#  user_id    :integer
#  name       :string(255)
#  date       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  position   :integer
#  date_start :integer
#  date_end   :integer
#

class Event < ActiveRecord::Base
  belongs_to :relic
  belongs_to :user
  belongs_to :photo

  attr_accessible :date, :name, :position, :photo_id, :relic_id, :as => [:default, :admin]
  attr_accessible :user_id, :relic_id, :as => [:admin]

  acts_as_list :scope => :relic

  validates :relic, :user, :name, :date, :presence => true

  include CanCan::Authorization

  has_paper_trail :skip => [:created_at, :updated_at]

  before_validation :parse_date
  validate :date_must_be_parsed, :if => :date_changed?

  def date_must_be_parsed
    if date_start.blank? || date_end.blank?
      errors.add(:date, I18n.t("errors.messages.date_must_be_parsed"))
    end
  end

  def parse_date
    self.date_start, self.date_end = DateParser.new(date).results
  end
end
