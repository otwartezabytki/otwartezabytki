class RecentRevision
  attr_accessor :version

  class << self
    def revisions
      Rails.cache.fetch("recent_revisions_#{I18n.locale}", :expires_in => 5.minutes) do
        Version.order('id DESC').limit(100).includes(:item).map do |version|
          new(:version => version).to_relic_hash
        end.compact.uniq { |relic_hash| relic_hash[:relic_id] }
      end.first(10)
    end
  end

  def initialize attrs = {}
    attrs.each do |key, value|
      send("#{key}=", value)
    end
  end

  def significant_changeset
    version.changeset.reject { |_, v| v.try(:length) == 2 and v[1].blank? }
  end

  def changes
    changed_fields = significant_changeset.keys
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
      return nil if ['relic', 'alert'].inlcude? version.item_type.downcase
      I18n.t("views.pages.home.revision_change.destroy.#{version.item_type.downcase}")
    else
      nil
    end
  end

  def relic
    return @relic if defined? @relic
    @relic = (version.item.is_a?(Relic) ? version.item : version.item.try(:relic))
  end

  def to_relic_hash
    return nil if relic.blank? or !relic.build_finished? or significant_changeset.blank?
    return nil if version.item.respond_to?(:saved?) and !version.item.saved?
    {
      :relic_id => relic.id,
      :slug => relic.to_param,
      :identification => relic.identification,
      :image_url => relic.main_photo.file.url(:icon),
      :changes => changes,
      :created_at => version.created_at,
      :alt_text => set_alternate_text
    }
  rescue ArgumentError => e
    nil
  end

  def set_alternate_text
    if relic.present? and relic.main_photo.present?
      if relic.main_photo.alternate_text.blank?
        "#{relic.identification} #{relic.main_photo.description}"
      else
        relic.main_photo.alternate_text
      end
    end
  end

end
