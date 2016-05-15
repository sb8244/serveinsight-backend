Rails.application.routes.draw do
  resource :user, only: [:show]
  resources :users, only: [:index]
  resource :organization, only: [:show, :create]
  resources :invites, only: [:create, :index]

  post '/auth/:provider/callback', to: 'auth#callback'
end
