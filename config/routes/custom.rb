resources :user_resources, only: [:index]
get "/proposals/:proposal_id/dashboard/campaign", to: "dashboard#campaign", as: :proposal_dashbord_campaign

resources :proposal_notifications, only: [:new, :create, :show, :edit, :update, :destroy]

resources :unregistered_newsletter_subscribers, only: [:create]

scope path: "unregistered_newsletter_subscribers" do
  get "confirm_subscription/:confirmation_token", to: "unregistered_newsletter_subscribers#confirm_subscription", as: :unregistered_newsletter_subscribers_confirm_subscription
  get "unsubscribe/:unsubscribe_token", to: "unregistered_newsletter_subscribers#unsubscribe", as: :unregistered_newsletter_subscribers_unsubscribe
end
