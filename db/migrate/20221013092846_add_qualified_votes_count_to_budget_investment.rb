class AddQualifiedVotesCountToBudgetInvestment < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_investments, :qualified_votes_count, :integer, default: 0
  end
end
