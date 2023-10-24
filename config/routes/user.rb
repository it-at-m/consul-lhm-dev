resources :users, only: [:show] do
  resources :direct_messages, only: [:new, :create, :show]
  get :refresh_activities, on: :member
end
