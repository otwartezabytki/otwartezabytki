class Widget < ActiveRecord::Base
  attr_accessible :config, :as => [:default, :admin]

  serialize :config, Hash

  belongs_to :user
  belongs_to :widget_template

  before_create :generate_uid


  protected

  def generate_uid
    self.uid ||= Devise.friendly_token
  end

end
