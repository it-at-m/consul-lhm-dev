class AddShowSummaryInsteadOfQuestionsToPolls < ActiveRecord::Migration[5.2]
  def change
    add_column :polls, :show_summary_instead_of_questions, :boolean, default: false
  end
end
