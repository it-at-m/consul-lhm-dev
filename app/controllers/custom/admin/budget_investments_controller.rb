require_dependency Rails.root.join("app", "controllers", "admin", "budget_investments_controller").to_s

class Admin::BudgetInvestmentsController < Admin::BaseController
  def edit_physical_votes
    @investment = Budget::Investment.find(params[:id])
    if @investment.update(physical_votes: params[:budget_investment][:physical_votes])
      @answer_updated = "answered"
    end
  end
end
