namespace :projekt_management do
  root to: "dashboard#index"

  resources :projekt_phases, only: [:update, :destroy] do
    member do
      get :duration
      get :naming
      get :restrictions
      get :settings
      get :map
      patch :update_map
      get :projekt_labels
      get :sentiments
      get :projekt_questions
      get :projekt_livestreams
      get :projekt_events
      get :milestones
      get :projekt_notifications
      get :projekt_arguments
      get :formular
      get :formular_answers
    end

    resources :formular, only: [] do
      resources :formular_fields, only: [:new, :create, :edit, :update, :destroy] do
        collection do
          post :order_formular_fields
        end
      end
      resources :formular_follow_up_letters, only: [:create, :edit, :update, :destroy] do
        member do
          post :send_emails
          get :preview
          get :restore_default_view
        end
      end
    end

    resources :projekt_labels, except: %i[index show]
    resources :sentiments, except: %i[index show]
    resources :projekt_questions, except: %i[index show] do
      post "/answers/order_answers", to: "questions/answers#order_answers"
      collection do
        post :send_notifications
      end
    end
    resources :projekt_livestreams, only: [:create, :update, :destroy] do
      member do
        post :send_notifications
      end
    end
    resources :projekt_events, only: [:create, :update, :destroy] do
      member do
        post :send_notifications
      end
    end
    resources :milestones, controller: "projekt_phase_milestones", except: [:index, :show]
    resources :progress_bars, controller: "projekt_phase_progress_bars"
    resources :projekt_notifications, only: [:create, :update, :destroy]
    resources :projekt_arguments, only: [:create, :update, :destroy] do
      collection do
        post :send_notifications
      end
    end
  end
  resources :projekt_phase_settings, only: [:update]

  resources :projekts, only: %i[index edit update] do
    member do
      patch :update_standard_phase
      patch :update_map
    end

    resources :projekt_phases, only: [:create] do
      member do
        patch :toggle_active_status
      end
      collection do
        post :order_phases
      end
    end
  end

  resources :map_layers, only: [:update, :create, :edit, :new, :destroy]

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
