Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'thanks#index'

  get 'sessions/new'
  get 'sessions/create'
  post 'sessions/destroy'

  get 'thanks/new'
  get 'thanks/:id', to: 'thanks#show', as: :thanks_show
  get 'thanks', to: 'thanks#index'
  post 'thanks', to: 'thanks#create'

  get 'thanks/:id/dittos/new', to: 'dittos#new', as: :dittos_new
  post 'thanks/:id/dittos', to: 'dittos#create', as: :dittos_create
  get 'thanks/:id/links/new', to: 'links#new', as: :links_new
  post 'thanks/:id/links/create', to: 'links#create', as: :links_create
end
