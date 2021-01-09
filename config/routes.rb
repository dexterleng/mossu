require 'sidekiq/web'

Rails.application.routes.draw do
  scope '/auth' do
    post '/signin', to: 'user_token#create'
    # post '/signup', to: 'users#create'
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :checks, only: [:index, :show, :create] do
    get 'report', to: 'checks#report'
    post 'start', to: 'checks#start'
    put 'upload_base_submission', to: 'checks#upload_base_submission'
  end
  resources :submissions, only: [:create]

  mount Sidekiq::Web => '/sidekiq'
end
