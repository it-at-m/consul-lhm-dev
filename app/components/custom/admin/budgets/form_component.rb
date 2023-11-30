require_dependency Rails.root.join("app", "components", "admin", "budgets", "form_component").to_s

class Admin::Budgets::FormComponent < ApplicationComponent
  def phases_select_options
    # Budget::Phase::PHASE_KINDS.map { |ph| [t("budgets.phase.#{ph}"), ph] }
    budget.phases.order(:id).map { |phase| [phase.name, phase.kind] }
  end

  def projekt_phase_options_for_selector
    if namespace == :admin_budgets_wizard && current_user.administrator?
      projekt_phases = ProjektPhase::BudgetPhase.all

    elsif namespace == :projekt_management_budgets_wizard && current_user.projekt_manager?
      projekt_phases = ProjektPhase::BudgetPhase.where(
        projekt_id: projekts_with_authorization_to("manage").ids
      )

    else
      projekt_phases = ProjektPhase::BudgetPhase.none

    end

    projekt_phases
      .reject { |pp| pp.budget.present? || pp.projekt.overview_page? }
      .map { |pp| ["#{pp.projekt.name} - #{pp.title}", pp.id] }
  end
end
