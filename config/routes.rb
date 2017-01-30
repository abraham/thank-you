Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'thanks/new'
  get 'thanks/:id', to: 'thanks#show', as: :thanks_show
  post 'thanks', to: 'thanks#create'
  get 'thanks', to: 'thanks#index'
  get 'thanks/:id/dittos/new', to: 'dittos#new', as: :dittos_new
  post 'thanks/:id/dittos', to: 'dittos#create', as: :dittos_create
end
