module AdminActions::BudgetWizard::Phases
  extend ActiveSupport::Concern

  include Admin::BudgetPhasesActions

  def index
    authorize!(:create, @budget) if @namespace.to_s.start_with?("projekt_management")

    render "admin/budgets_wizard/phases/index"
  end

  private

    def phases_index
      # admin_budgets_wizard_budget_budget_phases_path(@phase.budget, url_params)
      polymorphic_path([@namespace, @phase.budget, :budget_phases])
    end
end
