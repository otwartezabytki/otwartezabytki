# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: widgets
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  widget_template_id :integer
#  uid                :string(255)
#  config             :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Widget < ActiveRecord::Base
  attr_accessible :config, :as => [:default, :admin]

  serialize :config, Hash

  extend FriendlyId
  friendly_id :uid

  def snippet
    ""
  end

  class << self
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::AssetTagHelper

    def thumb
      "widgets/#{partial_name}.png"
    end

    def title
      I18n.t("widget.#{partial_name}.title")
    end

    def description
      I18n.t("widget.#{partial_name}.description")
    end

    def partial_name
      name.underscore.split('/').last
    end

    def serialized_attr_accessor(*args)
      args.flat_map{ |e| e.is_a?(Hash) ? e.to_a : [[e, nil]] }.each do |(method_name, default_value)|
        if default_value == true || default_value == false
          define_method(method_name) do
            !!((self.attributes['config'] || {})[method_name])
          end
        else
          define_method(method_name) do
            (self.attributes['config'] || {})[method_name] || default_value
          end
        end

        if default_value.is_a?(Integer)
          define_method("#{method_name}=") do |value|
            self.attributes['config'] ||= {}
            self.attributes['config'][method_name] = value.to_i
          end
        elsif default_value == true || default_value == false
          define_method("#{method_name}=") do |value|
            self.attributes['config'] ||= {}
            self.attributes['config'][method_name] = string_to_bool(value)
          end
        else
          define_method("#{method_name}=") do |value|
            self.attributes['config'] ||= {}
            self.attributes['config'][method_name] = value
          end
        end

        attr_accessible method_name, "#{method_name}=", :as => [:default, :admin]
      end
    end
  end

  protected

  before_create :generate_uid

  def generate_uid
    self.uid ||= Devise.friendly_token
  end

  def string_to_bool(value)
    return true if value == true || value =~ (/(true|t|yes|y|1)$/i)
    return false if value == false || value.blank? || value =~ (/(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{value}\"")
  end
end
