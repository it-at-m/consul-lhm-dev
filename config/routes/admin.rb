namespace :admin do
  root to: "dashboard#index"

  # custom projekt routes
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

  resources :projekts, only: [:index, :edit, :create, :update, :destroy] do
    member do
      get :order_up
      get :order_down
      patch :update_standard_phase
      patch :quick_update
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
    resources :settings, controller: "projekt_settings", only: [:update] do
      member do
        patch :update_default_projekt_footer_tab
      end
    end
  end

  resources :map_layers, only: [:update, :create, :edit, :new, :destroy]

  # custom individual groups routes
  resources :individual_groups do
    resources :individual_group_values, as: :values do
      get :search_user, on: :member
      post :add_user, on: :member
      delete :remove_user, on: :member
    end
  end

  # custom age restriction routes
  resources :age_restrictions

  # custom deficiency reports routes
  scope module: :deficiency_reports, path: :deficiency_reports, as: :deficiency_report do
    resources :officers, only: [:index, :create, :destroy] do
      get :search, on: :collection
    end
    resources :categories,  only: %i[index new create edit update destroy]
    resources :statuses,    only: %i[index new create edit update destroy] do
      collection do
        post "order_statuses"
      end
    end
    resources :settings, only: :index
    resources :areas, except: :show
  end

  resources :deficiency_reports, only: [:index, :show] do
    resources :audits, only: :show, controller: "deficiency_report_audits"
  end

  # custom projekt managers
  resources :projekt_managers, only: [:index, :create, :destroy] do
    get :search, on: :collection
  end

  # custom modal notifications routes
  resources :modal_notifications, except: :show

  # custom routes for registered addresses
  resources :registered_addresses, only: %i[index] do
    collection { post :import }
  end
  resources :registered_address_groupings, only: %i[index edit update destroy]
  resources :registered_address_streets, only: %i[index]

  resources :organizations, only: :index do
    get :search, on: :collection
    member do
      put :verify
      put :reject
    end
  end

  resources :hidden_users, only: [:index, :show] do
    member do
      put :restore
      put :confirm_hide
    end
  end

  resources :hidden_budget_investments, only: :index do
    member do
      put :restore
      put :confirm_hide
    end
  end

  resources :hidden_debates, only: :index do
    member do
      put :restore
      put :confirm_hide
    end
  end

  resources :debates, only: [:index, :show, :update]

  resources :proposals, only: [:index, :show, :update] do
    member { patch :toggle_selection }
    resources :milestones, controller: "proposal_milestones"
    resources :progress_bars, except: :show, controller: "proposal_progress_bars"
  end

  resources :hidden_proposals, only: :index do
    member do
      put :restore
      put :confirm_hide
    end
  end

  resources :hidden_proposal_notifications, only: :index do
    member do
      put :restore
      put :confirm_hide
    end
  end

  resources :budgets, except: [:create, :new] do
    member do
      patch :publish
      put :calculate_winners
      put :recalculate_winners # custom
    end

    resources :groups, except: [:index, :show], controller: "budget_groups" do
      resources :headings, except: [:index, :show], controller: "budget_headings"
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

  resources :milestone_statuses, only: [:index, :new, :create, :update, :edit, :destroy]

  resources :signature_sheets, only: [:index, :new, :create, :show]

  resources :banners, only: [:index, :new, :create, :edit, :update, :destroy] do
    collection { get :search }
  end

  resources :hidden_comments, only: :index do
    member do
      put :restore
      put :confirm_hide
    end
  end

  resources :comments, only: :index

  resources :tags, only: [:index, :create, :update, :destroy]

  resources :officials, only: [:index, :edit, :update, :destroy] do
    get :search, on: :collection
  end

  resources :settings, only: [:index, :update]
  put :update_map, to: "settings#update_map"
  put :update_content_types, to: "settings#update_content_types"

  resources :moderators, only: [:index, :create, :destroy] do
    get :search, on: :collection
  end

  resources :valuators, only: [:show, :index, :edit, :update, :create, :destroy] do
    get :search, on: :collection
    get :summary, on: :collection
  end

  resources :valuator_groups

  resources :managers, only: [:index, :create, :destroy] do
    get :search, on: :collection
  end

  namespace :sdg do
    resources :managers, only: [:index, :create, :destroy]
  end

  resources :administrators, only: [:index, :create, :destroy, :edit, :update] do
    get :search, on: :collection
  end

  resources :users, only: [:index, :show]

  scope module: :poll do
    resources :polls do
      get :booth_assignments, on: :collection
      patch :add_question, on: :member

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
    end

    resources :officers, only: [:index, :new, :create, :destroy] do
      get :search, on: :collection
    end

    resources :booths do
      get :available, on: :collection

      resources :shifts do
        get :search_officers, on: :collection
      end
    end

    resources :questions, shallow: true do
      resources :answers, except: [:index, :show], controller: "questions/answers", shallow: false
      resources :answers, only: [], controller: "questions/answers" do
        resources :images, controller: "questions/answers/images"
        resources :videos, controller: "questions/answers/videos", shallow: false
        resources :documents, only: [:index, :create], controller: "questions/answers/documents"
      end
      post "/answers/order_answers", to: "questions/answers#order_answers"
    end

    resource :active_polls, only: [:create, :edit, :update]
  end

  resources :verifications, controller: :verifications, only: :index do
    get :search, on: :collection
  end

  resource :activity, controller: :activity, only: :show

  resources :newsletters do
    member do
      post :deliver
    end
    get :users, on: :collection
  end

  resources :admin_notifications do
    member do
      post :deliver
    end
  end

  resources :system_emails, only: [:index] do
    get :view
    get :preview_pending
    put :moderate_pending
    put :send_pending
  end

  resources :emails_download, only: :index do
    get :generate_csv, on: :collection
  end

  resource :stats, only: :show do
    get :graph, on: :member
    get :budgets, on: :collection
    get :budget_supporting, on: :member
    get :budget_balloting, on: :member
    get :proposal_notifications, on: :collection
    get :direct_messages, on: :collection
    get :polls, on: :collection
    get :sdg, on: :collection
  end

  namespace :legislation do
    resources :processes do
      resources :questions
      resources :proposals do
        member { patch :toggle_selection }
      end
      resources :draft_versions
      resources :milestones
      resources :progress_bars, except: :show
      resource :homepage, only: [:edit, :update]
    end
  end

  namespace :api do
    resource :stats, only: :show
  end

  resources :geozones, only: [:index, :new, :create, :edit, :update, :destroy]

  namespace :site_customization do
    resources :pages, except: [:show] do
      resources :cards, except: [:show], as: :widget_cards
    end
    resources :images, only: [:index, :update, :destroy]
    resources :content_blocks, except: [:show]
    delete "/heading_content_blocks/:id", to: "content_blocks#delete_heading_content_block",as: "delete_heading_content_block"
    get "/edit_heading_content_blocks/:id", to: "content_blocks#edit_heading_content_block", as: "edit_heading_content_block"
    put "/update_heading_content_blocks/:id", to: "content_blocks#update_heading_content_block", as: "update_heading_content_block"
    resources :information_texts, only: [:index] do
      post :update, on: :collection
    end
    resources :documents, only: [:index, :new, :create, :destroy]
  end

  resource :homepage, controller: :homepage, only: [:show]

  namespace :widget do
    resources :cards
    resources :feeds, only: [:update]
  end

  namespace :dashboard do
    resources :actions, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :administrator_tasks, only: [:index, :edit, :update]
  end

  resources :local_census_records
  namespace :local_census_records do
    resources :imports, only: [:new, :create, :show]
  end

  resource :machine_learning, controller: :machine_learning, only: [:show] do
    post :execute, on: :collection
    delete :cancel, on: :collection
  end
end

resolve "Milestone" do |milestone|
  [*resource_hierarchy_for(milestone.milestoneable), milestone]
end

resolve "ProgressBar" do |progress_bar|
  [*resource_hierarchy_for(progress_bar.progressable), progress_bar]
end

resolve "Audit" do |audit|
  [*resource_hierarchy_for(audit.associated || audit.auditable), audit]
end

resolve "Widget::Card" do |card, options|
  [*resource_hierarchy_for(card.cardable), card]
end

resolve "Budget::Group" do |group, options|
  [group.budget, :group, options.merge(id: group)]
end

resolve "Budget::Heading" do |heading, options|
  [heading.budget, :group, :heading, options.merge(group_id: heading.group, id: heading)]
end

resolve "Budget::Phase" do |phase, options|
  [phase.budget, :phase, options.merge(id: phase)]
end

resolve "Poll::Booth" do |booth, options|
  [:booth, options.merge(id: booth)]
end

resolve "Poll::BoothAssignment" do |assignment, options|
  [assignment.poll, :booth_assignment, options.merge(id: assignment)]
end

resolve "Poll::Shift" do |shift, options|
  [:booth, :shift, options.merge(booth_id: shift.booth, id: shift)]
end

resolve "Poll::Officer" do |officer, options|
  [:officer, options.merge(id: officer)]
end

resolve "Poll::Question::Answer" do |answer, options|
  [:question, :answer, options.merge(question_id: answer.question, id: answer)]
end

resolve "Poll::Question::Answer::Video" do |video, options|
  [:video, options.merge(id: video)]
end
