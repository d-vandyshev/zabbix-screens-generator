Rails.application.routes.draw do
  # Sessions
  root 'sessions#new'
  post '/', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  # Application
  get 'generator', to: 'application#generator'
  post 'generator', to: 'application#generator_post'
  post 'screen', to: 'application#screen'
  post 'change_locale', to: 'application#change_locale'

  # Screens
  get 'screens/new'
  get 'screens/create'
end
