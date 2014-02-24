# -*- encoding : utf-8 -*-
RoutingFilter::Locale.include_default_locale = true
Otwartezabytki::Application.routes.draw do
  filter :locale,    :exclude => /^\/(admin|users\/auth)/
  mount Tolk::Engine => '/admin/tolk', :as => 'tolk'

  # Active Admin can cause migrations to fail...
  ActiveAdmin.routes(self) rescue nil

  devise_for :users, :path_names => {
    :sign_in => 'login', :sign_out => 'logout',
  }, :controllers => {
    :registrations => "users/registrations",
    :sessions => "users/sessions",
    :passwords => "users/passwords",
    :omniauth_callbacks => "users/omniauth_callbacks"
  }

  resources :tags, :only => :index

  resources :users, :only => [:show, :edit, :update] do
    get :checked_relics
    get :my_routes
    delete :remove_avatar
  end

  resources :relics, :except => [:new, :create, :destroy] do
    member do
      match 'section/:section/edit', :to => 'relics#edit', :as => 'edit_section'
      match 'section/:section', :to => 'relics#show', :as => 'section', :via => :get
      match 'section/:section', :to => 'relics#update', :as => 'section', :via => :put
      get :download_zip
      post :adopt
      post :unadopt
      get :print
    end

    resources :photos, :documents, :entries, :links, :events
    resources :alerts, :only => [:new, :create]
  end

  resource :relicbuilder, :only => [:new, :update, :create] do
    get :administrative_level
    get :address
    get :geodistance
    get :details
    match 'photos', :via => [:get, :delete]
  end

  match '/widgets', :to => "widgets#index"

  namespace :widgets do
    with_options :only => [:show, :edit, :create, :update] do |w|
      w.resources :map_searches, :path => "/map_search"
      w.resources :add_relics, :path => "/add_relics"
      w.resources :add_alerts, :path => "/add_alerts"
    end
    resources :directions, :path => "/direction", except: [:index] do
      member do
        get :print
        get :configure
        get :preview
      end
    end

    resource :add_alert, :path => "/add_alert"
  end

  resources :translations, :only => [:edit, :update], :constraints => {:id => /[\w.]+/ }

  namespace :api do
    namespace :v1 do

      resource :info do
        get :relics
        get :places
        get :relic_photos
      end

      resources :relics do
        resources :photos
        collection do
          get :clusters
        end
      end

      # resources :voivodeships, :only => [:index, :show]
      # resources :districts, :only => [:index, :show]
      # resources :communes, :only => [:index, :show]
      resources :places, :only => [:index, :show, :results]
      resources :users, :only => [] do
        collection do
          get :api_key_request
        end
      end
    end
  end

  get 'suggester/query'
  get 'suggester/place'
  get 'suggester/place_from_poland', :as => :place_from_poland

  resources :tags, :only => [:create]

  get 'geocoder/search'

  match "/strony/pobierz-dane"        => 'relics#download',                 :as => 'download_page'
  match "/strony/o-projekcie"         => 'pages#show', :id => 'about',      :as => 'about_page'
  match "/strony/kontakt"             => 'pages#show', :id => 'contact',    :as => 'contact_page'
  match "/strony/pomoc"               => 'pages#show', :id => 'help',       :as => 'help_page'
  match "/strony/dowiedz-sie-wiecej"  => 'pages#show', :id => 'more',       :as => 'more_page'
  match "/strony/regulamin"           => 'pages#show', :id => 'terms',      :as => 'terms_page'
  match "/strony/prywatnosc"          => 'pages#show', :id => 'privacy',    :as => 'privacy_page'
  match "/strony/cookie-policy"       => 'pages#show', :id => 'cookies',    :as => 'cookies_page'
  match "/facebook/share_close"       => 'pages#show', :id => 'share_close'
  match "/hello"                      => 'pages#hello', :id => 'hello', :as => :hello

  I18n.available_locales.each do |locale|
    match "#{I18n.t('routes.pages', :locale => locale)}/:id" => 'pages#show', :as => :"#{locale.to_s.underscore}_page"
  end

  root :to => 'pages#show', :id => 'home'
end
