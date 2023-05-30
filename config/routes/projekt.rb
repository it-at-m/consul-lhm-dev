resources :projekts, only: [:index, :show] do
  resources :projekt_questions, only: [:index, :show]
  resources :projekt_question_answers, only: [:create, :update]

  collection do
    get :comment_phase_footer_tab
    get :debate_phase_footer_tab
    get :proposal_phase_footer_tab
    get :voting_phase_footer_tab
  end

  member do
    get :json_data
    get :map_html
    get :selector_hint_html
  end
end

post "update_selected_parent_projekt", to: "projekts#update_selected_parent_projekt"

get :events, to: "projekt_events#index", as: :projekt_events

resources :projekt_livestreams, only: [:show] do
  member do
    post :new_questions
  end
end

get "/projekt_phases/:id/selector_hint_html", to: "projekt_phases#selector_hint_html"
