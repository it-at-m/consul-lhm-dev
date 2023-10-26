resource :account, controller: "account", only: [:show, :update, :delete] do
  get :erase, on: :collection
  get :refresh_activities, on: :collection
end

resource :subscriptions, only: [:edit, :update] do
  delete :cancel_projekts, on: :collection
end
