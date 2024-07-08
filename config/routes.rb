Rails.application.routes.draw do
  get 'twilio/webhook'
  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users
  ActiveAdmin.routes(self)
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Users routes
  get 'users', to: 'users#index', as: 'users'
  get 'users/new', to: 'users#new', as: 'new_user'
  post 'users', to: 'users#create'
  get 'users/:id/edit', to: 'users#edit', as: 'edit_user'
  patch 'users/:id', to: 'users#update'
  put 'users/:id', to: 'users#update'
  delete 'users/:id', to: 'users#destroy'

  # Bookings routes
  resources :bookings, only: [:create, :show, :index] do
    post 'payment_success', on: :collection
  end

  post '/webhooks/razorpay', to: 'webhooks#razorpay'
 
  get 'custom_admin_dashboard', to: 'admin#dashboard', as: :custom_admin_dashboard

  # Payments routes
  get 'payments', to: 'payments#index', as: 'payments'
  get 'payments/new', to: 'payments#new', as: 'new_payment'
  post 'payments', to: 'payments#create'
  get 'payments/:id', to: 'payments#show', as: 'payment'
  get 'payments/:id/edit', to: 'payments#edit', as: 'edit_payment'
  patch 'payments/:id', to: 'payments#update'
  put 'payments/:id', to: 'payments#update'
  delete 'payments/:id', to: 'payments#destroy'
  get '/payment_pending', to: 'payments#pending'

  # Camps routes
  get 'camps', to: 'camps#index', as: 'camps'
  get 'camps/new', to: 'camps#new', as: 'new_camp'
  post 'camps', to: 'camps#create'
  get 'camps/:id', to: 'camps#show', as: 'camp'
  get 'camps/:id/edit', to: 'camps#edit', as: 'edit_camp'
  patch 'camps/:id', to: 'camps#update'
  put 'camps/:id', to: 'camps#update'
  delete 'camps/:id', to: 'camps#destroy'

  get 'camps/category/:category', to: 'camps#category', as: 'camps_category'

  # Root route
  root 'camps#index'

  # Twilio webhook
  post '/twilio/webhook', to: 'twilio#webhook'

  # Admin custom actions for CSV and JSON downloads
  namespace :admin do
    resources :camps do
      collection do
        get :download_csv
        get :download_json
      end
    end
    resources :bookings
    resources :payments
  end
end
