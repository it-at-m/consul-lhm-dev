class ProjektManagement::BudgetsController < ProjektManagement::BaseController
  include AdminActions::Budgets

  def index
    @budgets = budgets_with_authorization.send(@current_filter).order(created_at: :desc).page(params[:page])

    render "admin/budgets/index"
  end

  private

    def budgets_with_authorization
      authorized_projekt_phases_ids = ProjektPhase::BudgetPhase.where(
        projekt_id: projekts_with_authorization_to("manage").ids
      ).ids
      Budget.where(projekt_phase_id: authorized_projekt_phases_ids)
    end
end
