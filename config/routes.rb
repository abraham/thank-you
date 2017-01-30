Rails.application.routes.draw do
  get 'thanks/new'
  post 'thanks', to: 'thanks#create'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
