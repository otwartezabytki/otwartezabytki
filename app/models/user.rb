class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :email, :role, :as => :admin

  validates :role, :inclusion => { :in => ["admin", "user"] }

  has_many :suggestions

  def admin?
    role == 'admin'
  end

  def password_required?
    admin? && super
  end

  def email_required?
    admin? && super
  end

end