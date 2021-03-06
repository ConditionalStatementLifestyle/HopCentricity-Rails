Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post '/beers', to: 'beer#search'
      post '/reviews', to: 'review#create'
      post '/userReviews', to: 'review#user_reviews'
      resources :review, only: [:update, :destroy]
    end
  end 
  post '/login', to: 'auth#login'
end
