Rails.application.routes.draw do
  get 'passwords/create'

  devise_for :users, controllers: { confirmations: 'confirmations', passwords: 'passwords', sessions: 'sessions' }
  namespace :api do
    get 'globals', to: 'globals#show'
    resources :contributions
    resources :groups
    resources :matchers
    resources :memberships
    resources :payments
    resources :pictures do
      collection do
        post 'upload'
      end
    end
    resources :projects
    resources :trips
    resources :users
  end
end
