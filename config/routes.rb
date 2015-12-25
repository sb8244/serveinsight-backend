Rails.application.routes.draw do
  resource :user, only: [:show]
  resource :organization, only: [:show, :create]

  post '/auth/:provider/callback', to: 'auth#callback'
end
