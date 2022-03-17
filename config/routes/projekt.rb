resources :projekts, only: [:index, :show]

post 'update_selected_parent_projekt', to: "projekts#update_selected_parent_projekt"
