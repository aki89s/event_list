Rails.application.routes.draw do
  resources :likes
  resources :follows
  resources :events
  resources :prefectures
  resources :users
  mount V1::API => '/'
end
