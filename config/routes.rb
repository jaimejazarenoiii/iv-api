Rails.application.routes.draw do
  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      # Dashboard endpoint
      get 'dashboard', to: 'dashboard#index'
      
      # Resource endpoints
      resources :spaces, only: [:index, :show, :create, :update, :destroy] do
        member do
          delete :image, action: :destroy_image
        end
        # Nested storages for creating/listing within a space
        resources :storages, only: [:index, :create], controller: 'storages'
      end
      
      resources :storages, only: [:index, :show, :create, :update, :destroy] do
        member do
          delete :image, action: :destroy_image
          post :move, action: :move
        end
      end

      resources :items, only: [:index, :show, :create, :update, :destroy] do
        collection do
          get :low_stock
          get :out_of_stock
        end
        member do
          delete :image, action: :destroy_image
          post :move, action: :move
        end
      end

      # Browse endpoints for incremental selection
      get 'browse/spaces', to: 'browse#spaces'
      get 'browse/storages', to: 'browse#storages'

      resources :categories, only: [:index, :show, :create, :update, :destroy]

      resources :purchase_sessions, only: [:index, :show, :create, :update, :destroy]

      resource :subscription, only: [:show, :update]

      # Profile endpoints
      resource :profile, only: [:show, :update], controller: 'profiles' do
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
