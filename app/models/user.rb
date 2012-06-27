class User < ActiveRecord::Base
  has_many :suggestions

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :registration
  attr_accessible :email, :password, :password_confirmation, :role, :as => :admin

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
      UserMailer.welcome_email(self, self.password).deliver
    end

  end

  # We don't require password because it is sent on e-mail
  def password_required?
    false
  end


end