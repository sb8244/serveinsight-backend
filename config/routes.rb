Rails.application.routes.draw do
  resource :user

  post '/auth/:provider/callback', to: 'auth#callback'
end
