class RecentRevision
  attr_accessor :version

  class << self
    def next(offset = 0)
      new({:version => Version.order('id DESC').offset(offset).first})
    end

    def recently_modified
      recently_modified = []
      start, count = 0, Version.count
      while(recently_modified.size < 5 and start < count)
        relic_hash = self.next(start).to_relic_hash
        if relic_hash.present? and !recently_modified.any? {|e| e[:relic_id] == relic_hash[:relic_id]}
          recently_modified << relic_hash
        end
        start += 1
      end
      recently_modified
    end
  end

  def initialize attrs = {}
    attrs.each do |key, value|
      send("#{key}=", value)
    end
  end

  def changes
    changed_fields = version.changeset.keys
    case version.event
    when 'update'
      if version.item_type.downcase == 'relic'
        changed_fields.map do |k|
          I18n.t("views.pages.home.revision_change.update.#{version.item_type.downcase}.#{k}")
        end.compact.join(', ')
      else
        I18n.t("views.pages.home.revision_change.update.#{version.item_type.downcase}")
      end
    when 'create'
      I18n.t("views.pages.home.revision_change.create.#{version.item_type.downcase}")
    when 'destroy'
      I18n.t("views.pages.home.revision_change.destroy.#{version.item_type.downcase}")
    else
      nil
    end
  end

  def relic
    return @relic if defined? @relic
    @relic = (self.version.item.is_a?(Relic) ? self.version.item : self.version.item.try(:relic))
  end

  def to_relic_hash
    return {} if relic.blank?
    {
      :relic_id => relic.id,
      :slug => relic.to_param,
      :identification => relic.identification,
      :image_url => relic.main_photo.file.url(:icon),
      :changes => changes
    }
  end

end