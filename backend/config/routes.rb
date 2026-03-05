require "sidekiq/web"

Rails.application.routes.draw do
  scope "/api" do
    mount Sidekiq::Web => "/sidekiq"
    devise_for :users,
               controllers: {
                 sessions: "users/sessions"
               }
    resources :users, controller: "users"
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
