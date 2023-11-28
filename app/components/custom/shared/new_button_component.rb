class Shared::NewButtonComponent < ApplicationComponent
  delegate :can?, :current_user,
           :sanitize,
           :link_to_signin, :link_to_signup, :link_to_verify_account, to: :helpers

  def initialize(projekt_phase: nil, resources_name: nil, query_params: nil)
    @projekt_phase = projekt_phase
    @resources_name = resources_name
    @query_params = query_params
  end

  def render?
    return false if @projekt_phase&.selectable_by_admins_only? && (current_user.blank? || !(current_user.administrator? || current_user.projekt_manager&.allowed_to?("manage", @projekt_phase.projekt)))
    return true if current_user.blank?
    return true if @projekt_phase&.projekt&.overview_page? # projects overview page

    # resources index page
    if @resources_name.present?
      return Projekt.top_level.selectable_in_selector(@resources_name, current_user).any?
    end

    if @projekt_phase.is_a?(ProjektPhase::BudgetPhase) # projekt page footer tab for budgets
      can? :create, Budget::Investment.new(budget: @projekt_phase.budget)
    else
      true # all other pages including footer tabs
    end
  end

  private

    def permission_problem_key
      if current_user.blank?
        @permission_problem_key ||= :not_logged_in

      elsif @projekt_phase.present?
        @permission_problem_key ||= @projekt_phase.permission_problem(current_user)

      end
    end

    def permission_problem_message(permission_problem_key)
      sanitize(
        t(path_to_key(permission_problem_key),
              sign_in: link_to_signin,
              sign_up: link_to_signup,
              verify: link_to_verify_account,
              city: Setting["org_name"],
              geozones: @projekt_phase&.geozone_restrictions_formatted,
              age_restriction: @projekt_phase&.age_restriction_formatted,
              restricted_streets: @projekt_phase&.street_restrictions_formatted,
              individual_group_values: @projekt_phase&.individual_group_value_restriction_formatted
        )
      )
    end

    def path_to_key(permission_problem_key)
      if @projekt_phase &&
          I18n.exists?("custom.projekt_phases.permission_problem.new_button_component.#{@projekt_phase.name}.#{permission_problem_key}")
        "custom.projekt_phases.permission_problem.new_button_component.#{@projekt_phase.name}.#{permission_problem_key}"
      else
        "custom.projekt_phases.permission_problem.new_button_component.shared.#{permission_problem_key}"
      end
    end

    def link_params_hash
      link_params = {}
      permitted_query_params = %i[order]

      if @projekt_phase.present?
        link_params[:projekt_phase_id] = @projekt_phase.id
        link_params[:projekt_id] = @projekt_phase.projekt.id
      end

      link_params[:origin] = "projekt" if controller_name == "pages"

      link_params.merge!(@query_params.permit(permitted_query_params).to_h) if @query_params.present?

      link_params
    end

    def new_button_classes
      classes = %w[button -orange new-resource-button]

      if @projekt_phase.class.name.in?(["ProjektPhase::ProposalPhase", "ProjektPhase::DebatePhase"]) ||
          @resources_name.in?(["proposals", "debates"])
        classes << "js-preselect-projekt"
      end

      classes.join(" ")
    end

    def new_button_html
      if @projekt_phase.is_a?(ProjektPhase::BudgetPhase)
        button_text = @projekt_phase&.cta_button_name.presence || t("budgets.investments.index.sidebar.create")
        link_to button_text,
                new_budget_investment_path(@projekt_phase.budget, projekt_phase_id: @projekt_phase, projekt_id: @projekt),
                class: new_button_classes

      elsif @projekt_phase.is_a?(ProjektPhase::DebatePhase) || @resources_name == "debates"
        button_text = @projekt_phase&.cta_button_name.presence || t("debates.index.start_debate")
        link_to button_text, new_debate_path(link_params_hash),
          class: new_button_classes

      elsif @projekt_phase.is_a?(ProjektPhase::ProposalPhase) || @resources_name == "proposals"
        button_text = @projekt_phase&.cta_button_name.presence || t("proposals.index.start_proposal")
        link_to button_text, new_proposal_path(link_params_hash),
          class: new_button_classes,
          data: { turbolinks: false }

      end
    end
end
