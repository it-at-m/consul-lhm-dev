resources :projekts, only: [:index, :show] do
  member do
    get :json_data
  end
end

post 'update_selected_parent_projekt', to: "projekts#update_selected_parent_projekt"
