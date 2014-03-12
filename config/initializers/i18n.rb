# # -*- encoding : utf-8 -*-
require 'i18n/backend/pluralization'
require 'i18n/backend/memoize'
require 'i18n/backend/active_record'

if Tolk::Translation.table_exists?
  # activerecord backend support
  I18n.backend = I18n::Backend::ActiveRecord.new
  I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Pluralization)

  # simple backend supprt
  I18n::Backend::Simple.send(:include, I18n::Backend::Memoize)
  I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)

  # chain backends
  I18n.backend = I18n::Backend::Chain.new(I18n.backend, I18n::Backend::Simple.new)
end

# define I18n collator method
module I18n
  class << self
    def twitter_cldr_supported_locale
      TwitterCldr.supported_locale?(I18n.locale) ? I18n.locale : :pl
    end
    def collator
      TwitterCldr::Collation::Collator.new(twitter_cldr_supported_locale)
    end
  end
end

# setting up default locale form I18n casue that "string".localize will get proper localization
def TwitterCldr.get_locale
  I18n.twitter_cldr_supported_locale.to_sym
end
