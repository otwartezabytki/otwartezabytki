# -*- encoding : utf-8 -*-
Otwartezabytki::Application.routes.draw do
  # under construction
  # match '*path' => 'pages#show', :id => 'under_construction'
  # root :to      => 'pages#show', :id => 'under_construction'


  mount Tolk::Engine => '/admin/tolk', :as => 'tolk'
  ActiveAdmin.routes(self)

  devise_for :users, :path_names => {
    :sign_in => 'login', :sign_out => 'logout',
  }, :controllers => {
    :registrations => "users/registrations",
    :sessions => "users/sessions",
    :passwords => "users/passwords"
  }
  resources :tags, :only => :index

  resources :relics, :except => [:new, :create, :destroy] do
    member do
      match 'section/:section/edit', :to => 'relics#edit', :as => 'edit_section'
      match 'section/:section', :to => 'relics#show', :as => 'section', :via => :get
      match 'section/:section', :to => 'relics#update', :as => 'section', :via => :put
      get :download_zip
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
  end

  resources :translations, :only => [:edit, :update], :constraints => {:id => /[\w.]+/ }

  namespace :api do
    namespace :v1 do

      resource :info do
        get :relics
        get :places
      end

      resources :relics

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

  match "/strony/pobierz-dane"    => 'relics#download', :as => 'download'

  match "/strony/o-projekcie"     => 'pages#show', :id => 'about', :as => 'about'
  match "/strony/kontakt"         => 'pages#show', :id => 'contact'
  match "/strony/pomoc"           => 'pages#show', :id => 'help'
  match "/strony/dowiedz-sie-wiecej" => 'pages#show', :id => 'more'
  match "/strony/regulamin" => 'pages#show', :id => 'terms'
  match "/strony/prywatnosc" => 'pages#show', :id => 'privacy'
  match "/facebook/share_close" => 'pages#show', :id => 'share_close'
  match "/hello"                  => 'pages#hello', :id => 'hello', :as => :hello

  root :to => 'pages#show', :id => 'home'
end
