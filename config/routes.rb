Rails.application.routes.draw do
  resource :user, only: [:show]
  resource :organization_membership, only: [:show]
  resources :organization_memberships, only: [:index, :destroy] do
    collection do
      put :bulk_update
    end
  end

  resource :organization, only: [:show, :create]
  resources :invites, only: [:create, :index]

  post '/auth/:provider/callback', to: 'auth#callback'
end
