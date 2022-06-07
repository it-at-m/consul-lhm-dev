class ChangeUserCostEstimateColumnsInBudgetInvestments < ActiveRecord::Migration[5.2]
  def change
    change_column :budget_investments, :user_cost_estimate, :string
  end
end
