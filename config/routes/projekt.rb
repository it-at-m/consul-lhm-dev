resources :projekts, only: [:index, :show] do
  resources :projekt_questions, only: [:index, :show]
  resources :projekt_question_answers, only: [:create, :update]

  member do
    get :json_data
    get :map_html
  end
end


post 'update_selected_parent_projekt', to: "projekts#update_selected_parent_projekt"
