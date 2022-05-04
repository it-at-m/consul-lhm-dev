class AddUserCostEstimateToBudgetInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_investments, :user_cost_estimate, :integer
  end
end
