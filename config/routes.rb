Rails.application.routes.draw do
  get 'thanks/new'
  get 'thanks/:id', to: 'thanks#show', as: :thanks_show
  post 'thanks', to: 'thanks#create'
  get 'thanks', to: 'thanks#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
