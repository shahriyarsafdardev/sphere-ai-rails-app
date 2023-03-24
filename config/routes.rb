Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :users, only: %i[create update] do
        collection do
          post :login
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
    end
  end
end
