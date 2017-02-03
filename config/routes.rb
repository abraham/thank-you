Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'thanks#index'

  get 'alpha/join/:token', to: 'alpha#join', as: :alpha_join

  resources :sessions
  resources :thanks do
    resources :dittos, only: [:new, :create]
    resources :links, only: [:new, :create]
  end
end
