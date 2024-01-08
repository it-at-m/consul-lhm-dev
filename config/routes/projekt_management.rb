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

  resources :budgets, except: [:create, :new] do
    member do
      patch :publish
      put :calculate_winners
      put :recalculate_winners # custom
    end

    resources :budget_investments, only: [:index, :show, :edit, :update] do
      # member { patch :toggle_selection }
      member do #custom
        patch :toggle_selection
        patch :edit_physical_votes
      end

      resources :audits, only: :show, controller: "budget_investment_audits"
      resources :milestones, controller: "budget_investment_milestones"
      resources :progress_bars, except: :show, controller: "budget_investment_progress_bars"
    end

    resources :budget_phases, only: [:edit, :update] do
      member { patch :toggle_enabled }
    end
  end

  namespace :budgets_wizard do
    resources :budgets, only: [:create, :new, :edit, :update] do
      resources :groups, only: [:index, :create, :edit, :update, :destroy] do
        resources :headings, only: [:index, :create, :edit, :update, :destroy]
      end

      resources :phases, as: "budget_phases", only: [:index, :edit, :update] do
        member { patch :toggle_enabled }
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

  namespace :site_customization do
    resources :pages, only: [:update]
    resources :content_blocks, only: [:edit, :update]
  end

  scope module: :poll do
    resources :polls do
      get :booth_assignments, on: :collection
      patch :add_question, on: :member
      post :send_notifications, on: :member

      resources :booth_assignments, only: [:index, :show, :create, :destroy] do
        get :search_booths, on: :collection
        get :manage, on: :collection
      end

      resources :officer_assignments, only: [:index, :create, :destroy] do
        get :search_officers, on: :collection
        get :by_officer, on: :collection
      end

      resources :recounts, only: :index
      resources :results, only: :index

      resources :questions, only: [] do
        post :order_questions, on: :collection
      end
    end

    # resources :officers, only: [:index, :new, :create, :destroy] do
    #   get :search, on: :collection
    # end

    # resources :booths do
    #   get :available, on: :collection

    #   resources :shifts do
    #     get :search_officers, on: :collection
    #   end
    # end

    resources :questions, shallow: true do
      resources :answers, except: [:index, :show], controller: "questions/answers", shallow: false
      resources :answers, only: [], controller: "questions/answers" do
        resources :images, controller: "questions/answers/images"
        resources :videos, controller: "questions/answers/videos", shallow: false
        resources :documents, only: [:index, :create], controller: "questions/answers/documents"
        post :order_answers, on: :collection
      end
    end

    # resource :active_polls, only: [:create, :edit, :update]
  end

  namespace :legislation do
    resources :processes do
      # resources :questions
      # resources :proposals do
      #   member { patch :toggle_selection }
      # end
      resources :draft_versions
      # resources :milestones
      # resources :progress_bars, except: :show
      # resource :homepage, only: [:edit, :update]
    end
  end
end
