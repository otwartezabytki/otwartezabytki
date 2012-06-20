# -*- encoding : utf-8 -*-
Otwartezabytki::Application.routes.draw do

  ActiveAdmin.routes(self)

  devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout' }

  resources :relics, :only => [:index, :show, :edit, :update] do
    member do
      get :review, :to => "suggestions#new"
      post :submit_review, :to => "suggestions#create"
      get :thank_you, :to => "suggestions#thank_you"
    end
  end

  resources :tags, :only => [:create]

  get 'geocoder/search'

  root :to => "relics#index"
end
