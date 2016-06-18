Rails.application.routes.draw do
  resource :user, only: [:show]
  resource :organization_membership, only: [:show]
  resources :organization_memberships, only: [:index, :destroy] do
    collection do
      put :bulk_update
    end
  end
  resources :mention_names, only: [:index]

  resource :organization, only: [:show, :create]
  resources :invites, only: [:create, :index]
  resources :comments, only: [:create]
  resources :passups, only: [:index, :create] do
    member do
      post :complete
    end
  end

  resources :survey_templates, except: [:destroy]
  resources :survey_instances, only: [:index, :show] do
    collection do
      get :top_due
    end
  end
  resources :completed_surveys, only: [:index, :create]
  resources :reviewable_surveys, only: [:index] do
    collection do
      get :reports
    end

    member do
      post :mark_reviewed
    end
  end

  post '/auth/:provider/callback', to: 'auth#callback'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
