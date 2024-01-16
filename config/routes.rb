require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'
  post '/api/users/verify-email', to: 'users#verify_email'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  namespace :api do
    put '/users/:id/shop', to: 'users#update_shop'
    put '/users/:id/profile', to: 'users#update'
  end
end
