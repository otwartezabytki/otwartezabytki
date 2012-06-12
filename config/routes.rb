# -*- encoding : utf-8 -*-
Otwartezabytki::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout' }

  resources :relics, :only => [:index, :show, :edit, :update]
  root :to => "relics#index"
end
