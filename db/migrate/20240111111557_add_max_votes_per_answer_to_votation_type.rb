class AddMaxVotesPerAnswerToVotationType < ActiveRecord::Migration[5.2]
  def change
    add_column :votation_types, :max_votes_per_answer, :integer, default: nil
  end
end
