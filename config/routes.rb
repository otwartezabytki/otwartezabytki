# -*- encoding : utf-8 -*-
Otwartezabytki::Application.routes.draw do

  ActiveAdmin.routes(self)

  devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout' }

  resources :relics, :only => [:edit, :update, :index, :show, :edit, :update], :path_names => { :edit => 'review' } do
    member do
      get :thank_you
    end
  end

  resources :tags, :only => [:create]

  get 'geocoder/search'

  root :to => "relics#index"
end
