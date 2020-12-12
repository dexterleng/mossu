Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :checks, only: [:index, :show, :create] do
    get 'report', to: 'checks#report'
    post 'start', to: 'checks#start'
  end
  resources :submissions, only: [:create]
end
