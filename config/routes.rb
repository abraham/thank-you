Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'thanks#index'

  get 'alpha/join/:token', to: 'alpha#join', as: :alpha_join

  get 'sessions/new'
  post 'sessions/start'
  get 'sessions/finish'
  delete 'sessions/destroy'

  resources :thanks do
    resources :dittos
  end

  get 'thanks/:id/links/new', to: 'links#new', as: :links_new
  post 'thanks/:id/links/create', to: 'links#create', as: :links_create
end
