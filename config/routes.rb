Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'deeds#index'

  get 'about/terms'
  get 'about/privacy'

  resource :sessions, only: [:new, :create, :destroy] do
    get :finish
  end

  resources :deeds, only: [:new, :create, :show, :index] do
    root to: redirect('/')
    resources :thanks, only: [:new, :create]
    resources :links, only: [:new, :create]
  end
end
