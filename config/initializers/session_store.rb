# -*- encoding : utf-8 -*-
# Be sure to restart your server when you modify this file.

if Rails.env.development?
  Otwartezabytki::Application.config.session_store :cookie_store, key: '_oz_session'
else
  Otwartezabytki::Application.config.session_store :cookie_store, key: '_oz_session', domain: Settings.oz.host
end