Rails.application.routes.draw do
  scope '/api' do
    devise_for :users,
               path: 'users',
               class_name: 'Users::User',
               controllers: {
                 sessions: 'users/sessions',
                 registrations: 'users/registrations'
               }
    resources :users, except: [:create], controller: 'users/users'
    post 'users/create', to: 'users/users#create'
    get '/profile/me', to: 'users/profile#me'

    resources :documents, controller: 'documents/documents' do
      collection do
        get :to_review
      end
      member do
        get :refresh_ocr
        get :refresh_nlp
        post :approve
        post :reject
      end
    end
  end
end
