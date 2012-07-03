class User < ActiveRecord::Base
  has_many :suggestions

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :registration
  attr_accessible :email, :password, :password_confirmation, :role, :as => :admin
  attr_accessor :force_password_required

  validates :role, :inclusion => { :in => ["admin", "user"] }

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

    model.before_save do
      generated_password = [0..9, 'a'..'z', 'A'..'Z'].map(&:to_a).reduce(:+).sample(8).join
      self.password = generated_password
      self.password_confirmation = generated_password
    end

  end

  # We don't require password because it is sent on e-mail
  def password_required?
    force_password_required
  end

  def corrected_relic_ids
    return @corrected_relic_ids if defined? @corrected_relic_ids
    @corrected_relic_ids = suggestions.joins(:relic).where("relics.edit_count < 3").group(:relic_id).pluck(:relic_id)
  end
  
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
  end

end