Rails.application.routes.draw do
  get 'tweets/new'
  post 'tweets/create'
  get 'tweets/:tweet_id/thanks/new', to: 'thanks#new', as: :new_thank
  post 'tweets/:tweet_id/thanks', to: 'thanks#create', as: :create_thank

  resources :thanks

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
