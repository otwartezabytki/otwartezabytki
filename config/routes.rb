# -*- encoding : utf-8 -*-
Otwartezabytki::Application.routes.draw do
  resources :relics, :only => [:index, :show, :edit, :update]
  root :to => "relics#index"
end
