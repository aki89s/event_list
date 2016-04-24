Rails.application.routes.draw do
  resources :prefectures
  resources :users
  mount V1::API => '/'
end
