Rails.application.routes.draw do
  # Sessions
  root 'sessions#new'
  post '/', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  # Application
  post 'change_locale', to: 'application#change_locale'

  # Screens
  get 'screens/new'
  post 'screens/create'

  get 'hosts', to: 'hosts#index'

  # Errors
  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
end
