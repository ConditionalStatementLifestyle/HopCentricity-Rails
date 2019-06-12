Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post '/beers', to: 'beer#search'
    end
  end 
  post '/login', to: 'auth#login'
end
