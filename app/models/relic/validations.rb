# -*- encoding : utf-8 -*-
# this module caches location fields for quick access
module Relic::Validations
  extend ActiveSupport::Concern

  included do
    validates :place, :presence => true, :unless => :foreign_relic?

    # build step validations
    with_options :if => lambda{ |o| o.details_step? or o.photos_step? } do |step|
      step.validates :reason, :identification, :presence => true
    end

    with_options :if => :photos_step? do |step|
      step.validates :description, :presence => true
    end

    validates :identification, :presence => true, :if => :identification_changed?
    validate :date_must_be_parsed, :if => :dating_of_obj_changed?

    # api create validation
    validates :place, :identification, :description, :reason, :presence => true, :if => :created_via_api
  end

  def date_must_be_parsed
    if date_start.blank? || date_end.blank?
      errors.add(:dating_of_obj, I18n.t("errors.messages.date_must_be_parsed"))
    end
  end

  def invalid_step
    return 'details' if [:reason, :identification].any?{|k| errors.keys.include?(k)}
    return 'photos'  if [:description].any?{|k| errors.keys.include?(k)}
    'address'
  end

  def invalid_step_view
    self.build_state = "#{invalid_step}_step"
    invalid_step
  end


end
