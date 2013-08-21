# clear recently modified relic on homepage
class Version
  def watched_type
    case event
      when "update" then "modified"
      when "create" then "added"
      when "delete" then "removed"
    end
  end

  def relic
    return nil if item_type != "Relic"

    @relic ||= Relic.find(item_id)
  end

  def user
    @user ||= User.find(whodunnit)
  end
end

Version.instance_eval do
  after_create { Rails.cache.delete('views/recently-modified') }

  scope :relics, proc { where(:item_type => "Relic") }
  scope :adopted_by, proc { |user| where(:item_id => user.user_relics.map(&:relic_id).map(&:to_s)) }
end
