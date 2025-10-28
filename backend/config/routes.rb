require "sidekiq/web"

Rails.application.routes.draw do
  scope "/api" do
    mount Sidekiq::Web => "/sidekiq"
    devise_for :users,
               controllers: {
                 sessions: "users/sessions",
                 registrations: "users/registrations"
               }
    resources :users, except: [ :create ], controller: "users"
    post "users/create", to: "users#create"
    get "/profile/me", to: "profile#me"

    resources :documents, controller: "documents" do
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
