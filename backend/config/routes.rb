Rails.application.routes.draw do
  scope '/api' do
    devise_for :users,
               path: 'users',
               controllers: {
                 sessions: 'users/sessions',
                 registrations: 'users/registrations'
               }

    resources :users, except: [:create]
    post '/users/create', to: 'users#create'

    get '/profile/me', to: 'profile#me'
    resources :documents, only: [:create, :index]
  end
end
