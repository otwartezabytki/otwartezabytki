# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  role                   :string(255)      default("user")
#  username               :string(255)
#  seen_relic_order       :string(255)      default("asc")
#  api_key                :string(255)
#  api_secret             :string(255)
#

class User < ActiveRecord::Base
  has_many :suggestions
  has_many :seen_relics
  has_many :widgets

  has_many :user_relics
  has_many :relics, :through => :user_relics

  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauth_providers => [:facebook]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :registration, :terms_of_service
  attr_accessible :email, :password, :password_confirmation, :role, :as => :admin
  attr_accessor :force_password_required, :current_password

  attr_accessible :avatar, :language, :current_password

  mount_uploader :avatar, AvatarUploader

  validates :role, :inclusion => { :in => ["admin", "user"] }
  validates :language, :inclusion => { :in => Settings.oz.locale.available.map(&:to_s) }
  validates :username, :email, :uniqueness => { :message => I18n.t('activemodel.errors.messages.already_taken') }

  def admin?
    role == 'admin'
  end

  # Set this to true to enable additional validations and password generation
  attr_accessor :registration
  def registration?; registration.present? end
  def registered?; email.present? end

  # We require e-mail only on registration as nil-user exist
  def email_required?
    registration?
  end

  # Other logic on user registration
  with_options :if => :registration? do |model|

    model.validates :username,
      :uniqueness => true, :presence => true, :format => /[\w\.]/,
      :length => { :maximum => 30, :minimum => 3 }

    model.validates_acceptance_of :terms_of_service, :accept => true
    model.validates :terms_of_service, presence: true

    model.before_save do
      self.password = self.password_confirmation = Devise.friendly_token[0,20]
      # Generate API key
      self.generate_api_key!
    end

  end

  # We don't require password because it is sent on e-mail
  def password_required?
    force_password_required
  end

  def mark_relic_as_seen(relic_id)
    sr = self.seen_relics.find_or_create_by_relic_id relic_id
    sr.touch
    if seen_relic_ids.first == relic_id
      self.seen_relic_order = (self.seen_relic_order == 'asc' ? 'desc' : 'asc')
      self.update_attribute(:seen_relic_order, self.seen_relic_order) if self.seen_relic_order_changed?
    end
  end

  def seen_relic_ids
    self.seen_relics.order("updated_at #{self.seen_relic_order}").pluck(:relic_id)
  end

  def earn_points
    return @earn_points if defined? @earn_points
    @earn_points = self.suggestions.not_skipped.count
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def generate_api_key!
    self.api_key = Devise.friendly_token
  end

  def generate_api_secret!
    self.api_secret = Devise.friendly_token
  end

  def ensure_api_keys_generated!
    generate_api_key!     unless api_key?
    generate_api_secret!  unless api_secret?
    save!
  end

  def adopted?(id)
    relics.exists?(id)
  end

  # def to_param
  #   self.username
  # end

  class << self
    def reset_password_by_token(attributes={})
      recoverable = find_or_initialize_with_error_by(:reset_password_token, attributes[:reset_password_token])
      if recoverable.persisted?
        if recoverable.reset_password_period_valid?
          recoverable.force_password_required = true
          recoverable.reset_password!(attributes[:password], attributes[:password_confirmation])
        else
          recoverable.errors.add(:reset_password_token, :expired)
        end
      end
      recoverable
    end

    def find_for_facebook_oauth(auth, signed_in_resource=nil)
      User.where(["email = ? OR (provider = ? AND uid = ?)", auth.info.email, auth.provider, auth.uid]).first_or_create do |user|
        user.username  ||= auth.extra.raw_info.name
        user.password  ||= Devise.friendly_token[0,20]
        user.provider  = auth.provider
        user.uid       = auth.uid
        user.email     = auth.info.email
      end
    end
  end
end
