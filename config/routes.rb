# -*- encoding : utf-8 -*-
Otwartezabytki::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout' }

  resources :relics, :only => [:index, :show, :edit, :update] do
    collection do
      get :suggester
    end
  end
  root :to => "relics#index"
end
