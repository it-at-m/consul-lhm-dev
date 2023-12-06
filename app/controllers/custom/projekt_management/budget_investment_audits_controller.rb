class ProjektManagement::BudgetInvestmentAuditsController < ProjektManagement::BaseController
  def show
    investment = Budget::Investment.find(params[:budget_investment_id])
    authorize!(:create, investment.budget) if @namespace == :projekt_management

    @audit = investment.own_and_associated_audits.find(params[:id])

    render "admin/audits/show"
  end
end
