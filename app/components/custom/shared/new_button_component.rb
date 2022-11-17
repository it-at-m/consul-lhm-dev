class Shared::NewButtonComponent < ApplicationComponent
  delegate :can?, :current_user,
           :sanitize,
           :link_to_signin, :link_to_signup, :link_to_verify_account, to: :helpers

  def initialize(projekt_phase: nil, resources_name: nil, url_params: nil)
    @projekt_phase = projekt_phase
    @resources_name = resources_name
    @url_params = url_params
  end

  private

    def show_new_button?
      return true if @projekt_phase.projekt&.overview_page? # projects overview page

      return Projekt.top_level.selectable_in_selector('debates', current_user).any? if @resources_name.present? # resources index page

      if @projekt_phase.is_a?(ProjektPhase::BudgetPhase) # projekt page footer tab for budgets
        can? :create, Budget::Investment.new(budget: @projekt_phase.projekt.budget)

      elsif @projekt_phase.present? # projekt page all other footer tabs
        @projekt_phase.projekt.all_ids_in_tree.any? { |id| Projekt.find(id).selectable?(@projekt_phase.resources_name, current_user) }

      end
    end

    def permission_problem_key
      if @projekt_phase.present?
				@permission_problem_key ||= @projekt_phase.permission_problem(current_user)

      elsif current_user.blank?
        @permission_problem_key ||= :not_logged_in
      end
    end

    def permission_problem_message(permission_problem_key)
      sanitize(
        t(path_to_key(permission_problem_key),
              sign_in: link_to_signin,
              sign_up: link_to_signup,
              verify: link_to_verify_account,
              city: Setting["org_name"],
              geozones: @projekt_phase.geozone_restrictions_formatted
        )
      )
    end

    def path_to_key(permission_problem_key)
      if I18n.exists? "custom.projekt_phases.permission_problem.new_button_component.#{@projekt_phase.name}.#{permission_problem_key}"
        "custom.projekt_phases.permission_problem.new_button_component.#{@projekt_phase.name}.#{permission_problem_key}"
      else
        "custom.projekt_phases.permission_problem.new_button_component.shared.#{permission_problem_key}"
      end
    end

    def link_params_hash
      link_params = {}

      link_params[:projekt_id] = selected_parent_projekt.id if selected_parent_projekt.present?
      link_params[:origin] = 'projekt' if controller_name == 'pages'
      link_params[:order] = @resources_order

      link_params
    end

    def new_button_html
      if @projekt_phase.is_a?(ProjektPhase::BudgetPhase)
        link_to t("budgets.investments.index.sidebar.create"),
                new_budget_investment_path(@projekt_phase.projekt.budget, origin: "projekt"),
                class: "button expanded"
      elsif @projekt_phase.is_a?(ProjektPhase::DebatePhase)
        link_to t("debates.index.start_debate"), new_debate_path( link_params_hash ), class: "button expanded js-preselect-projekt"
      end
    end
end
