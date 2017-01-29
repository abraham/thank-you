Rails.application.routes.draw do
  get 'statuses/new'
  post 'statuses/create'
  resources :thanks

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
