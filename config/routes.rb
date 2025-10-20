Rails.application.routes.draw do

  get "cocktail/elm"
  get "cocktail/halogen"
  get "cocktail/flame"

  get "elm_form/new"
  get "elm_form/index"
  post "elm_form/index"

  get "pure_script/show_halogen"
  get "pure_script/show_flame"
  get "re_script/show"

  post "api/list-files" => "api/files#list"
  #  second example for clarity
  get  "api/get-files"  => "api/files#get"

  get "home/page"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  root "home#page"
end
