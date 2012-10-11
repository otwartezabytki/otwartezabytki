# -*- encoding : utf-8 -*-
# config/initializers/pluralization.rb
require "i18n/backend/pluralization"
I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)
