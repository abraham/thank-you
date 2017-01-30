Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'thanks/new'
  get 'thanks/:id', to: 'thanks#show', as: :thanks_show
  get 'thanks', to: 'thanks#index'
  post 'thanks', to: 'thanks#create'
  get 'thanks/:id/dittos/new', to: 'dittos#new', as: :dittos_new
  post 'thanks/:id/dittos', to: 'dittos#create', as: :dittos
end
