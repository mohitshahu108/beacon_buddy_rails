Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      post "auth/send_verification", to: "auth#send_verification"
      post "auth/verify_email", to: "auth#verify_email"
      post "auth/google", to: "auth#google"
      post "auth/register", to: "auth#register"
      post "auth/login", to: "auth#login"
      post "auth/password/reset", to: "auth#password_reset"
      post "auth/password/confirm", to: "auth#password_confirm"
      post "auth/link_password", to: "auth#link_password"
      get "me", to: "auth#me"

      resources :beacons do
        member do
          post :join
          delete :leave
        end

        resources :participants, only: [] do
          member do
            patch :approve
            patch :reject
          end
        end
      end
    end
  end
end
