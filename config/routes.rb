Rails.application.routes.draw do
  resources :events
  resources :prefectures
  resources :users
  mount V1::API => '/'
end
