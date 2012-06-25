class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username
  attr_accessible :email, :role, :as => :admin

  validates :role, :inclusion => { :in => ["admin", "user"] }
  validates :username,
    :uniqueness => true, :presence => true, :format => /[\w\.]/, :length => { :maximum => 30, :minimum => 3 },
    :if => lambda { |c| c.suggestions.count >= 3 }

  has_many :suggestions

  before_save do
    if email_changed? && !admin?
      generated_password = [0..9, 'a'..'z', 'A'..'Z'].map(&:to_a).reduce(:+).sample(8).join
      self.password = generated_password
      self.password_confirmation = generated_password
      UserMailer.welcome_email(self, self.password).deliver
    end
  end

  def admin?
    role == 'admin'
  end

  def password_required?
    false
  end

  def email_required?
    admin? || self.suggestions.count >= 3
  end

end