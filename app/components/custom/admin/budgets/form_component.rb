require_dependency Rails.root.join("app", "components", "admin", "budgets", "form_component").to_s

class Admin::Budgets::FormComponent < ApplicationComponent
  def phases_select_options
    # Budget::Phase::PHASE_KINDS.map { |ph| [t("budgets.phase.#{ph}"), ph] }
    budget.phases.order(:id).map { |phase| [phase.name, phase.kind] }
  end
end
