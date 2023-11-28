class AddParentQuestionIdToPollQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :poll_questions, :parent_question_id, :integer
  end
end
