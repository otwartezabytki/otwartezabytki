# -*- encoding : utf-8 -*-
Otwartezabytki::Application.routes.draw do
  resources :relics
  root :to => "relics#index"
end
