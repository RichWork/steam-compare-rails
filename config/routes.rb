Rails.application.routes.draw do
  get 'welcome/index'
  root 'welcome#index'
  post 'auth/steam/callback' => 'welcome#auth_callback'
  get 'compare/index'
  resources :welcome do
    collection do
      get 'log_out'
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end