Rails.application.routes.draw do
  scope "api/auth" do
    devise_for :users, controllers: {
      sessions: "api/auth/sessions",
      registrations: "api/auth/registrations",
      confirmations: "api/auth/confirmations"
    }
  end

  namespace :api do

    resource :user, only: [:show]
    resource :organization_membership, only: [:show, :update]
    resources :organization_memberships, only: [:index, :destroy] do
      collection do
        put :bulk_update
      end
    end
    resources :mention_names, only: [:index]

    resource :organization, only: [:show, :create]
    resources :invites, only: [:create, :index]
    resources :comments, only: [:create]
    resources :passups, only: [:index, :show, :create] do
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
    resources :previous_insights, only: [:show]

    resources :notifications, only: [:index] do
      member do
        post :complete
      end

      collection do
        post :complete_all
      end
    end

    resources :answers, only: [:show]
    resources :goals, only: [:show]
    resources :shoutouts, only: [:index, :show, :create]
  end

  post "/auth/:provider/callback", to: "auth#callback"

  require "sidekiq/web"
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end if Rails.env.production?
  mount Sidekiq::Web => "/sidekiq"

  get "/rails/mailers" => "rails/mailers#index"
  get "/rails/mailers/*path" => "rails/mailers#preview"

  get "*path", to: "application#index"
  get "/surveys/managed/*id", constraints: { id: /\d*/ }, as: :managed_survey, to: "application#index"
  get "/passups/*id", constraints: { id: /\d*/ }, as: :passup, to: "application#index"
  get "/answers/*id", constraints: { id: /\d*/ }, as: :answer, to: "application#index"
  get "/goals/*id", constraints: { id: /\d*/ }, as: :goal, to: "application#index"
  get "/surveys/completed/*id", constraints: { id: /\d*/ }, as: :completed_survey, to: "application#index"
  get "/surveys/*id", constraints: { id: /\d*/ }, as: :survey, to: "application#index"
  get "/shoutouts/*id", constraints: { id: /\d*/ }, as: :shoutout, to: "application#index"
  root "application#index"
end
