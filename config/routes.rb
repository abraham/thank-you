Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'deeds#index'

  get 'about/terms'
  get 'about/privacy'

  get 'manifest', to: 'manifest#index'

  resources :deeds, only: [:new, :create, :show, :edit, :index, :update] do
    root to: redirect('/')
    get :drafts, on: :collection
    get :start, on: :collection
    post :etl, on: :collection
    post :publish
    resources :thanks, only: [:new, :create]
    resources :links, only: [:new, :create]
  end

  resource :sessions, only: [:new, :create, :destroy] do
    get :finish
  end

  resources :users, only: [:drafts] do
    get :drafts
  end
end
