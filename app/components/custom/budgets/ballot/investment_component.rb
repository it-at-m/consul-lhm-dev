require_dependency Rails.root.join("app", "components", "budgets", "ballot", "investment_component").to_s

class Budgets::Ballot::InvestmentComponent < ApplicationComponent
  private

    def delete_path
      budget_ballot_line_path(id: investment.id, budget_id: investment.budget.id)
    end
end
