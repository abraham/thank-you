Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'deeds#index'

  get 'about/terms'
  get 'about/privacy'

  get 'manifest', to: 'manifest#index'
  get 'firebase-messaging-sw', to: 'static#firebase_messaging_sw'

  get 'notifications', to: 'notifications#index'

  resources :deeds, only: [:new, :create, :show, :edit, :index, :update] do
    root to: redirect('/')
    get :popular, on: :collection
    get :drafts, on: :collection
    get :start, on: :collection
    post :etl, on: :collection
    post :publish
    resources :thanks, only: [:new, :create]
    resources :links, only: [:new, :create]
  end

  resource :subscriptions, only: [:create, :destroy, :show]

  resource :sessions, only: [:new, :create, :destroy] do
    get :finish
  end

  resources :users, only: [:drafts] do
    get :drafts
  end
end
