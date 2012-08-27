# == Schema Information
#
# Table name: entries
#
#  id         :integer          not null, primary key
#  relic_id   :integer
#  user_id    :integer
#  title      :string(255)
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Entry < ActiveRecord::Base
  belongs_to :relic
  belongs_to :user

  attr_accessible :body, :title,:as => [:default, :admin]
  attr_accessible :relic_id, :user_id, :as => :admin

  validates :relic, :title, :body, :presence => true

  include CanCan::Authorization

  has_paper_trail :skip => [:created_at, :updated_at]
end
