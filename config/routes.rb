# -*- encoding : utf-8 -*-
Otwartezabytki::Application.routes.draw do

  ActiveAdmin.routes(self)

  devise_for :users, :path_names => {
    :sign_in => 'login', :sign_out => 'logout',
  }, :controllers => {
    :registrations => "users/registrations",
    :sessions => "users/sessions",
    :passwords => "users/passwords"
  }

  resources :tags, :only => :index

  resources :relics, :only => [:edit, :update, :index, :show, :edit, :update] do
    resources :photos, :documents, :entries
    resources :links do
      collection do
        post :sort
      end
    end
    resources :events do
      collection do
        post :sort
      end
    end

    collection do
      get :suggester
    end

    member do
      get :corrected
      get :thank_you
      get :gonext
      match 'section/:section/edit', :to => 'relics#edit', :as => 'edit_section'
      match 'section/:section', :to => 'relics#show', :as => 'section', :via => :get
      match 'section/:section', :to => 'relics#update', :as => 'section', :via => :put
    end
  end

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

  root :to => 'high_voltage/pages#show', :id => 'home'
end
