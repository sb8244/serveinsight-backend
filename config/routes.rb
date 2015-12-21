Rails.application.routes.draw do
  resource :user, only: [:show]

  post '/auth/:provider/callback', to: 'auth#callback'
end
