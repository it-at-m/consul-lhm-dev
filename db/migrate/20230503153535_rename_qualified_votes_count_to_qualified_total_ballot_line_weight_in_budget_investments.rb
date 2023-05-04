class RenameQualifiedVotesCountToQualifiedTotalBallotLineWeightInBudgetInvestments < ActiveRecord::Migration[5.2]
  def change
    rename_column :budget_investments, :qualified_votes_count, :qualified_total_ballot_line_weight
  end
end
