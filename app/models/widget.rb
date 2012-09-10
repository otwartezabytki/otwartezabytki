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

  def config
    OpenStruct.new(self.attributes['config'])
  end

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
  end

  protected

  before_create :generate_uid

  def generate_uid
    self.uid ||= Devise.friendly_token
  end
end
