# -*- encoding : utf-8 -*-
class LocationBuilder
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :polish_place, :foreign_relic, :country_code, :original_name, :polish_name

  def initialize(attributes = {})
    attributes.each do |name, value|
      next unless respond_to?("#{name}=")
      send("#{name}=", value)
    end if attributes.present?
  end

  def persisted?
    false
  end

  def polish_place?
    @polish_place.present?
  end

  def foreign_relic?
    @foreign_relic == '1'
  end

  def foreign_address
    return "" unless foreign_relic?
    [Country.find(@country_code).name, @original_name, @polish_name].compact.join(', ')
  end
end
