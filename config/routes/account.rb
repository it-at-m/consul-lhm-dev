resource :account, controller: "account", only: [:show, :update, :delete] do
  get :erase, on: :collection
  get :refresh_activities, on: :collection
  get :edit_username, on: :member
  patch :update_username, on: :member
  get :edit_details, on: :member
  patch :update_details, on: :member
end

resource :subscriptions, only: [:edit, :update] do
  delete :cancel_projekts, on: :collection
end
