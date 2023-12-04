class Admin::BudgetPhasesController < Admin::BaseController
  include AdminActions::BudgetPhases

  private

    def phases_index
      admin_budget_path(@phase.budget)
    end
end
