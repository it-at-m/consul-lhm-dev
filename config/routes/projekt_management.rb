namespace :projekt_management do
  root to: "projekts#index"

  resources :projekts, only: %i[index edit update] do
    resources :projekt_questions, only: %i[new edit]
    resources :milestones, controller: "projekt_milestones", except: %i[index show]
    resources :progress_bars, controller: "projekt_progress_bars", except: %i[show]
  end

  namespace :site_customization do
    resources :pages, only: %i[edit update] do
      resources :cards, except: [:show], as: :widget_cards
    end
  end

  resources :proposals, only: :index do
    put :hide, on: :member
    put :moderate, on: :collection
  end

  resources :debates, only: :index do
    put :hide, on: :member
    put :moderate, on: :collection
  end

  resources :comments, only: :index do
    put :hide, on: :member
    put :moderate, on: :collection
  end

  resources :budget_investments, only: :index, controller: "budgets/investments" do
    put :hide, on: :member
    put :moderate, on: :collection
  end
end
