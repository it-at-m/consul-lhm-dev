namespace :officing do
  resources :polls, only: [:index] do
    get :final, on: :collection
    resources :results, only: [:new, :create, :index]

    resources :ballot_sheets, only: [:new, :create, :show, :index]
  end

  resource :booth, controller: "booth", only: [:new, :create]
  resource :residence, controller: "residence", only: [:new, :create]
  resources :voters, only: [:new, :create]

  namespace :offline_ballots do #custom
    get  ":budget_id/verify_user", action: :verify_user,           as: :verify_user
    post "find_or_create_user",    action: :find_or_create_user,   as: :find_or_create_user
    get  ":budget_id/investments", action: :investments,           as: :investments
  end

  root to: "dashboard#index"
end
