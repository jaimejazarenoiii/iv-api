Rails.application.routes.draw do
  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      # Resource endpoints
      resources :spaces, only: [:index, :show, :create, :update, :destroy] do
        member do
          delete :image, action: :destroy_image
        end
      end
      
      resources :storages, only: [:index, :show, :create, :update, :destroy] do
        member do
          delete :image, action: :destroy_image
        end
      end

      resources :items, only: [:index, :show, :create, :update, :destroy] do
        collection do
          get :low_stock
          get :out_of_stock
        end
        member do
          delete :image, action: :destroy_image
        end
      end

      resources :purchase_sessions, only: [:index, :show, :create, :update, :destroy]

      resource :subscription, only: [:show, :update]

      # Profile endpoints
      resource :profile, only: [:show, :update] do
        delete :image, action: :destroy_image
      end
    end
  end
  
  # Devise authentication routes (outside namespace to work properly)
  scope :api do
    scope :v1 do
      devise_for :users, 
        path: '', 
        path_names: {
          sign_in: 'login',
          sign_out: 'logout',
          registration: 'signup'
        },
        controllers: {
          sessions: 'api/v1/sessions',
          registrations: 'api/v1/registrations'
        },
        skip: [:sessions, :registrations]
      
      # Manually define only the routes we need for API
      devise_scope :user do
        post 'login', to: 'api/v1/sessions#create'
        delete 'logout', to: 'api/v1/sessions#destroy'
        post 'signup', to: 'api/v1/registrations#create'
      end
    end
  end
end
