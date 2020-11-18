Rails.application.routes.draw do
  root 'welcome#index'
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'signout', to: 'sessions#destroy'

  get "/dashboard", to: "dashboard#index"

  get "/login", to: "login#show"

  namespace :admin do
    resources :projects, only: [:show, :create]
  end

  resources :projects, only: [] do
    resources :clones, only: [:new, :create, :update, :destroy]
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
