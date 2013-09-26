require 'i18n/backend/base'
require 'tolk/phrase'
require 'tolk/translation'

module I18n
  module Backend
    class ActiveRecord
      autoload :Missing,     'i18n/backend/active_record/missing'

      module Implementation
        include Base, Flatten

        def available_locales
          begin
            Tolk::Locale.pluck(:name).uniq.map(&:to_sym)
          rescue ::ActiveRecord::StatementInvalid
            []
          end
        end

        def store_translations(locale, data, options = {})
          return "Sorry, but unsupported"
          escape = options.fetch(:escape, true)
          flatten_translations(locale, data, escape, false).each do |key, value|
            # Translation.locale(locale).lookup(expand_keys(key)).delete_all
            # Translation.create(:locale => locale.to_s, :key => key.to_s, :value => value)
          end
        end

      protected

        def lookup(locale, key, scope = [], options = {})
          separator = options[:separator] || I18n.default_separator
          key = normalize_flat_keys(locale, key, scope, separator)
          results = Rails.cache.fetch("i18n-#{[locale, key].join(separator)}".gsub(/\s/, "_")) do
            Tolk::Translation.lookup(locale, key).all
          end
          return nil if results.empty?

          translation = if results.first.phrase.key == key
            results.first.text
          else
            chop_range = (key.size + FLATTEN_SEPARATOR.size)..-1
            results.inject({}) do |hash, r|
              hash[r.phrase.key.slice(chop_range)] = r.text
              hash
            end
          end
          translation.respond_to?(:deep_symbolize_keys) ? translation.deep_symbolize_keys : translation
        end

        # For a key :'foo.bar.baz' return ['foo', 'foo.bar', 'foo.bar.baz']
        def expand_keys(key)
          key.to_s.split(FLATTEN_SEPARATOR).inject([]) do |keys, key|
            keys << [keys.last, key].compact.join(FLATTEN_SEPARATOR)
          end
        end
      end

      include Implementation
    end
  end
end
