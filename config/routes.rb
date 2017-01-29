Rails.application.routes.draw do
  get 'tweets/new'
  post 'tweets/create'
  resources :thanks

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
