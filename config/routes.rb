Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'deeds#index'

  get 'about/terms'
  get 'about/privacy'

  get 'manifest', to: 'manifest#index'

  resource :sessions, only: [:new, :create, :destroy] do
    get :finish
  end

  resources :deeds, only: [:new, :create, :show, :edit, :index, :update] do
    root to: redirect('/')
    post :publish
    get :draft, on: :collection
    resources :thanks, only: [:new, :create]
    resources :links, only: [:new, :create]
  end
end
