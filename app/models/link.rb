# == Schema Information
#
# Table name: links
#
#  id         :integer          not null, primary key
#  relic_id   :integer
#  user_id    :integer
#  name       :string(255)
#  url        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  position   :integer
#

class Link < ActiveRecord::Base
  belongs_to :relic
  belongs_to :user

  attr_accessible :name, :relic_id, :url, :user_id, :position

  acts_as_list :scope => :relic

  validates :relic, :user, :url, :name, :presence => true
  validates_format_of :url, :with => URI::regexp(%w(http https ftp)), :if => :url_changed?

  def shortened_url
    uri = URI::parse(url)
    shortened_path = uri.path
    shortened_path = "..." + shortened_path[-20..-1].to_s if shortened_path.length > 20
    "#{uri.host}/#{shortened_path}"
  end

  include CanCan::Authorization
end
