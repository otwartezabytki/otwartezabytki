# encoding: utf-8

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

  UrlCategories = ["artykuł prasowy", "blog/prywatna strona", "strona instytucji", "Wikipedia", "książka"]
  PaperCategories = ["encyklopedia", "przewodnik", "czasopismo", "książka"]

  belongs_to :relic
  belongs_to :user

  attr_accessible :name, :url, :position, :kind, :category, :formal_name, :as => [:default, :admin]
  attr_accessible :relic_id, :user_id, :as => :admin

  acts_as_list :scope => :relic


  validates_format_of :url, :with => URI::regexp(%w(http https ftp)), :if => :url_changed?

  validates :kind, :presence => true, :inclusion => { :in => ["url", "paper"] }

  validates :category, :presence => true, :inclusion => { :in => UrlCategories }, :if => :url?
  validates :category, :presence => true, :inclusion => { :in => PaperCategories }, :if => :paper?

  validates :relic, :user, :url, :name, :presence => true, :if => :url?
  validates :relic, :user, :formal_name, :name, :presence => true, :if => :paper?

  has_paper_trail :skip => [:created_at, :updated_at]

  def shortened_url
    uri = URI::parse(url)
    shortened_path = uri.path
    shortened_path = "..." + shortened_path[-20..-1].to_s if shortened_path.length > 20
    "#{uri.host}/#{shortened_path}"
  end


  def url?
    kind == "url"
  end

  def paper?
    kind == "paper"
  end

  include CanCan::Authorization
end
