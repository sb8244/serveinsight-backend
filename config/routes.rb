Rails.application.routes.draw do
  resource :user, only: [:show]
  resource :organization, only: [:show, :create]
  resources :invites, only: [:create, :index]

  post '/auth/:provider/callback', to: 'auth#callback'
end
