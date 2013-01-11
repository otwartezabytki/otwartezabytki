# # -*- encoding : utf-8 -*-
require 'i18n/backend/pluralization'
require 'i18n/backend/active_record'

# pluralization support
I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)
I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Pluralization)

# activerecord backend support
I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Cache)
I18n.cache_store = ActiveSupport::Cache.lookup_store(:dalli_store, { :namespace => "oz-i18n-#{Rails.env}", :expires_in => 1.month, :compress => true })
I18n.backend = I18n::Backend::Chain.new(I18n::Backend::ActiveRecord.new, I18n.backend)

# clear cache after transaltaion update
Tolk::Translation.instance_eval do
  after_save do
    # do not remove logger line !!!
    Rails.logger.error "clean i18n cache store"
    I18n.cache_store.clear
  end
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
