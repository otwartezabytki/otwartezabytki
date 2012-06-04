# -*- encoding : utf-8 -*-
Otwartezabytki::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :users, ActiveAdmin::Devise.config

  resources :relics, :only => [:index, :show, :edit, :update]
  root :to => "relics#index"
end
