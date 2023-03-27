# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users,
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations'
             }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :users, only: %i[create update] do
        collection do
          post :login
          patch :update_password
        end
        member do
          patch :change_password
          post :reset_password
        end
      end
      resources :postgres_references do
        member do
          get :query
        end
        collection do
          get :my_references
        end
      end
      resources :hubspot_references, only: %i[create update destroy]
    end
  end
end
