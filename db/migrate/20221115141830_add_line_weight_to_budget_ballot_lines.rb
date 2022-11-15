class AddLineWeightToBudgetBallotLines < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_ballot_lines, :line_weight, :integer, default: 1
  end
end
