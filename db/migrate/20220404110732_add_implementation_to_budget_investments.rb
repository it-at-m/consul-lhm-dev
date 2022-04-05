class AddImplementationToBudgetInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_investments, :implementation_performer, :integer, default: 0
    add_column :budget_investments, :implementation_contribution, :text
  end
end
