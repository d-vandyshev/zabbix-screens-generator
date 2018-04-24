Rails.application.routes.draw do
  # Sessions
  root 'sessions#new'
  post '/', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  # Application
  post 'change_locale', to: 'application#change_locale'

  # Screens
  get 'screens/new'
  post 'screens/new'
  post 'screens/create'
end
