class ProjektManagement::BudgetPhasesController < ProjektManagement::BaseController
  include AdminActions::BudgetPhases

  private

    def phases_index
      projekt_management_budget_path(@phase.budget)
    end
end
