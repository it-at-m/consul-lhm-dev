require_dependency Rails.root.join("app", "helpers", "budget_investments_helper").to_s

module BudgetInvestmentsHelper
  def default_active_investment_footer_tab?(tab)
    return true if tab == "comments" &&
                     projekt_feature?(@investment&.projekt, "budgets.show_comments")

    tab == "milestones" &&
      projekt_feature?(@investment&.projekt, "budgets.enable_investment_milestones_tab") &&
      !projekt_feature?(@investment&.projekt, "budgets.show_comments")
  end
end
