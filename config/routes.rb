Rails.application.routes.draw do
  post '/auth/:provider/callback', to: 'auth#callback'
end
