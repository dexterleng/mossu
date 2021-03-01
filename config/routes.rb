require 'sidekiq/web'

Rails.application.routes.draw do
  scope '/auth' do
    post '/signin', to: 'user_token#create'
    post '/signup', to: 'users#create'
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :checks, only: [:index, :show, :create] do
    get 'report', to: 'checks#report'
    post 'start', to: 'checks#start'
    put 'base_submission', to: 'checks#upload_base_submission'
  end
  resources :submissions, only: [:create]

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(username, Rails.application.credentials[:sidekiq_admin_user]) &
      ActiveSupport::SecurityUtils.secure_compare(password, Rails.application.credentials[:sidekiq_admin_password])
  end
  mount Sidekiq::Web => '/sidekiq'

  require 'sidekiq/prometheus/exporter'
  mount Sidekiq::Prometheus::Exporter => '/sidekiq_metrics'
end
