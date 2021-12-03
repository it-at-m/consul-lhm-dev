Rails.application.routes.draw do
  mount Ckeditor::Engine => "/ckeditor"
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  draw :account
  draw :admin
  draw :annotation
  draw :budget
  draw :comment
  draw :community
  draw :debate
  draw :devise
  draw :direct_upload
  draw :document
  draw :graphql
  draw :legislation
  draw :management
  draw :moderation
  draw :notification
  draw :officing
  draw :poll
  draw :proposal
  draw :related_content
  draw :sdg
  draw :sdg_management
  draw :tag
  draw :user
  draw :valuation
  draw :verification
  draw :projekt

  root "welcome#index"
  get "/welcome", to: "welcome#welcome"
  get "/consul.json", to: "installation#details"

  resources :stats, only: [:index]
  resources :images, only: [:destroy]
  resources :documents, only: [:destroy]
  resources :follows, only: [:create, :destroy]
  resources :remote_translations, only: [:create]

  # Deficiency reports
  resources :deficiency_reports, only: [:index, :show, :new, :create, :destroy] do
    member do
      get     :json_data
      post    :vote
      patch   :update_status
      patch   :update_category
      patch   :update_officer
      patch   :update_official_answer
      patch   :approve_official_answer
      put     :flag
      put     :unflag
    end
  end

  # More info pages
  get "help",             to: "pages#show", id: "help/index",             as: "help"
  get "help/how-to-use",  to: "pages#show", id: "help/how_to_use/index",  as: "how_to_use"
  get "help/faq",         to: "pages#show", id: "faq",                    as: "faq"

  # Static pages
  resources :pages, path: "/", only: [:show]

  # Post open answers
  post "polls/questions/:id/answers/update_open_answer",   to: "polls/questions#update_open_answer", as: :update_open_answer
  # Confirm poll participation
  post "polls/:id/confirm_participation",                  to: "polls#confirm_participation",        as: :poll_confirm_participation

  # Toggle user generateg images
  patch  "admin/proposals/:id/toggle_image",               to: "admin/proposals#toggle_image",       as: :admin_proposal_toggle_image
  patch  "admin/debates/:id/toggle_image",                 to: "admin/debates#toggle_image",         as: :admin_debate_toggle_image
end
