require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get '/health' => 'pages#health_check'
  get 'api-docs/v1/swagger.yaml' => 'swagger#yaml'

  # Existing route for updating user profile
  put 'api/users/:id/profile', to: 'users#update'

  # Add new route for user registration
  namespace :api, defaults: { format: :json } do
    post 'users/register', to: 'users#register'
  end

  # ... other existing routes can be added here
end
